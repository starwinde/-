import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/core/native/disturbance_api.g.dart';
import 'package:routinemon/core/native/usage_api.g.dart';
import 'package:routinemon/core/native/usage_bridge.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/disturbance/data/usage_log_repository.dart';
import 'package:routinemon/features/disturbance/domain/disturbance_intervention.dart';
import 'package:routinemon/features/schedule/application/active_schedule_provider.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

/// Foreground-only disturbance controller (T5.21).
///
/// Detects "active device usage" by observing app lifecycle: when routinemon
/// is paused while a schedule with `allowDisruption=true` is currently
/// running, the controller fires the intervention configured for that
/// schedule's `disruptionIntensity` via the native [DisturbanceApi].
///
/// Native side-effects (vibrate / launchHome / lockNow / overlays) fire
/// immediately on pause. Overlays are rendered via the native WindowManager
/// (TYPE_APPLICATION_OVERLAY) so they appear ON TOP of the foreground app
/// rather than only inside routinemon's own UI.
///
/// On L3 (lockNow), a periodic timer keeps locking the screen every 30s
/// until the schedule's end time. Cooldown is enforced by
/// [DisturbanceIntervention] (30s).
class DisturbanceController with WidgetsBindingObserver {
  /// Creates the controller.
  DisturbanceController({
    required this.ref,
    DisturbanceApi? api,
    DisturbanceIntervention? intervention,
  })  : _api = api ?? DisturbanceApi(),
        _intervention = intervention ?? DisturbanceIntervention();

  /// Riverpod ref for reading current active schedule.
  final Ref ref;

  final DisturbanceApi _api;
  final DisturbanceIntervention _intervention;

  /// 본인 패키지 — 사용 기록에서 항상 제외 (ADR 0004).
  static const _selfPackage = 'com.starwinde.routinemon';

  Timer? _periodicLockTimer;
  Timer? _periodicVibrateTimer;
  bool _started = false;
  bool _serviceRunning = false;

  /// 마지막 paused 시각. resumed 에서 사용 통계 윈도 시작점으로 사용.
  DateTime? _pausedAt;

  /// paused 시점의 active 일정 id (resumed 시 같은 일정 컨텍스트로 기록).
  int? _pausedScheduleId;

  /// Attaches the controller to widget lifecycle. Idempotent — repeated
  /// invocations from rebuilds do not register the observer multiple times.
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Detaches the controller.
  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _cancelPeriodicTimers();
    unawaited(_api.dismissOverlay());
    if (_serviceRunning) {
      _api.stopDisturbanceService();
      _serviceRunning = false;
    }
  }

  void _cancelPeriodicTimers() {
    _periodicLockTimer?.cancel();
    _periodicLockTimer = null;
    _periodicVibrateTimer?.cancel();
    _periodicVibrateTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(_onAppPaused());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_onAppResumed());
    }
  }

  Future<void> _onAppPaused() async {
    debugPrint('[Disturbance] paused');
    final user = ref.read(authProvider).value;
    debugPrint('[Disturbance] user=${user?.id}');
    if (user == null) return;
    final repo = ref.read(scheduleRepositoryProvider);
    final all = await repo.watchAllActive(user.id).first;
    final schedule = findCurrentActiveSchedule(all, DateTime.now());
    debugPrint(
        '[Disturbance] schedule=${schedule?.id} allow=${schedule?.allowDisruption} intensity=${schedule?.disruptionIntensity} (rows=${all.length})');
    if (schedule == null) return;
    if (!schedule.allowDisruption) return;

    // ADR 0004: 모든 단계가 paused 시점을 기록 (resumed 에서 사용 통계 수집).
    _pausedAt = DateTime.now();
    _pausedScheduleId = schedule.id;

    final level = DisturbanceLevel.fromInt(schedule.disruptionIntensity);
    final action = _intervention.onActiveUsage(DateTime.now(), level);
    debugPrint(
        '[Disturbance] level=$level action=$action vibrate=${action?.vibrateMs} launchHome=${action?.launchHome}');
    if (action == null) return;

    // L0 = observe-only — 그 외 액션 모두 0/false. 아래 분기는 자연 스킵되지만
    // 명시 early-return 으로 가독성 유지.
    if (level == DisturbanceLevel.l0) return;

    if (!_serviceRunning) {
      await _api.startDisturbanceService();
      _serviceRunning = true;
    }
    if (action.vibrateMs > 0) {
      await _api.vibrate(action.vibrateMs, -1);
    }
    await _renderOverlay(action);
    if (action.launchHome) {
      await _api.launchHome();
    }
    if (action.periodicSec > 0) {
      _startPeriodicAction(action, schedule.endTime);
    }
  }

  Future<void> _onAppResumed() async {
    final user = ref.read(authProvider).value;
    Schedule? activeSchedule;
    if (user != null) {
      final repo = ref.read(scheduleRepositoryProvider);
      final all = await repo.watchAllActive(user.id).first;
      activeSchedule = findCurrentActiveSchedule(all, DateTime.now());
    }

    // ADR 0004: paused→resumed 사이의 사용 통계를 누적. 모든 단계 공통.
    final pausedAt = _pausedAt;
    final pausedScheduleId = _pausedScheduleId;
    _pausedAt = null;
    _pausedScheduleId = null;
    debugPrint(
      '[Disturbance] resumed pausedAt=$pausedAt pausedScheduleId=$pausedScheduleId user=${user?.id}',
    );
    if (user != null && pausedAt != null) {
      await _recordUsage(
        userId: user.id,
        scheduleId: pausedScheduleId,
        rangeStart: pausedAt,
        rangeEnd: DateTime.now(),
      );
    }
    if (activeSchedule == null) {
      _cancelPeriodicTimers();
      _intervention.resetForNewSchedule();
      await _api.dismissOverlay();
      if (_serviceRunning) {
        await _api.stopDisturbanceService();
        _serviceRunning = false;
      }
    }
  }

  /// paused→resumed 사이의 `queryUsageStats` 결과를 `usage_logs` 에 누적.
  /// 본인 패키지 [_selfPackage] 는 항상 제외. native API 실패는 swallow
  /// (사용자 차단 금지).
  Future<void> _recordUsage({
    required String userId,
    int? scheduleId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    if (rangeEnd.isBefore(rangeStart)) return;
    try {
      // Padding ±2분 — UsageStatsManager 가 짧은 윈도에서 ACTIVITY_PAUSED
      // 이벤트를 누락하는 케이스 대응 (페어 매칭 보장).
      const pad = Duration(minutes: 2);
      final queryStart = rangeStart.subtract(pad);
      final queryEnd = rangeEnd.add(pad);
      final usageApi = ref.read(usageApiProvider);
      final stats = await usageApi.queryUsageStats(
        queryStart.millisecondsSinceEpoch,
        queryEnd.millisecondsSinceEpoch,
      );
      debugPrint('[Usage] queryUsageStats returned ${stats.length} entries');
      final useful = <AppUsageInfo>[
        for (final s in stats)
          if (s.totalTimeInForeground > 0 && s.packageName != _selfPackage) s,
      ];
      debugPrint('[Usage] useful=${useful.length} after self-filter');
      if (useful.isEmpty) return;
      final repo = ref.read(usageLogRepositoryProvider);
      for (final s in useful) {
        await repo.insert(
          userId: userId,
          scheduleId: scheduleId,
          packageName: s.packageName,
          totalMs: s.totalTimeInForeground,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
        );
      }
      debugPrint(
        '[Usage] recorded ${useful.length} packages for schedule=$scheduleId',
      );
    } on Exception catch (e) {
      debugPrint('[Usage] queryUsageStats failed (swallowed): $e');
    }
  }

  Future<void> _renderOverlay(DisturbanceAction action) async {
    if (action.blackOverlayMs > 0) {
      await _api.showBlackOverlay(action.blackOverlayMs);
    } else if (action.blockOverlay) {
      await _api.showBlockFullscreen();
    } else if (action.blockDialog) {
      await _api.showBlockDialog(3);
    }
  }

  void _startPeriodicAction(DisturbanceAction action, DateTime? until) {
    _cancelPeriodicTimers();
    _periodicLockTimer = Timer.periodic(
      Duration(seconds: action.periodicSec),
      (t) async {
        if (until != null && DateTime.now().isAfter(until)) {
          _cancelPeriodicTimers();
          await _api.dismissOverlay();
          if (_serviceRunning) {
            await _api.stopDisturbanceService();
            _serviceRunning = false;
          }
          return;
        }
        await _renderOverlay(action);
        if (action.periodicLaunchHome) {
          await _api.launchHome();
        }
        if (action.periodicLockDevice) {
          await _api.lockDevice();
        }
      },
    );

    final vibrateSec = action.periodicVibrateSec > 0
        ? action.periodicVibrateSec
        : action.periodicSec;
    if (action.periodicVibrateMs > 0 && vibrateSec > 0) {
      _periodicVibrateTimer = Timer.periodic(
        Duration(seconds: vibrateSec),
        (t) async {
          if (until != null && DateTime.now().isAfter(until)) {
            t.cancel();
            return;
          }
          await _api.vibrate(action.periodicVibrateMs, -1);
        },
      );
    }
  }
}

/// Provides a singleton [DisturbanceController]. Lifecycle is bound to the
/// root widget via [DisturbanceController.start]/[DisturbanceController.stop].
final disturbanceControllerProvider = Provider<DisturbanceController>(
  (ref) => DisturbanceController(ref: ref),
);

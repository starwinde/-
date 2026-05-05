import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/core/native/disturbance_api.g.dart';
import 'package:routinemon/core/native/usage_bridge.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/focus_tracking/data/session_repository.dart';
import 'package:routinemon/features/schedule/application/active_schedule_provider.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

/// Periodic trigger that auto-starts a focus session when a schedule's
/// `[startTime, endTime]` window opens, polls device usage every 60s, and
/// closes the session when the window closes.
///
/// Pattern mirrors [DisturbanceController] but drives [SessionRepository]
/// — it does not surface UI overlays. The controller is foreground-only
/// (rules.md §3.5) — when the app is in the background, the
/// [FocusForegroundService] continues sampling and caches deltas, which
/// are merged on resume.
class ScheduleSessionTrigger {
  ScheduleSessionTrigger({required this.ref, DisturbanceApi? api})
      : _api = api ?? DisturbanceApi();

  /// Riverpod ref used to read repos / providers each tick.
  final Ref ref;

  /// Native bridge for sticky 일정 알림 (USB 알림 패턴).
  final DisturbanceApi _api;

  /// Routinemon's own package — excluded from "phone usage" classification.
  static const _selfPackage = 'com.starwinde.routinemon';

  /// 한 minute window 내에 폰을 5초 이상 사용했으면 그 1 minute 은 blacklist
  /// 로 카운트한다.
  static const _useThresholdMs = 5000;

  Timer? _timer;
  bool _started = false;

  /// Currently active session id (null when between schedules).
  int? _activeSessionId;

  /// Schedule id matching [_activeSessionId] (so a different schedule
  /// becoming active forces a session swap).
  int? _activeScheduleId;

  /// Last poll wall-clock — bounds the next usage query window.
  int _lastPollMs = DateTime.now().millisecondsSinceEpoch;

  /// Start the periodic ticker. Idempotent.
  void start() {
    if (_started) return;
    _started = true;
    _lastPollMs = DateTime.now().millisecondsSinceEpoch;
    // 즉시 1회 tick — 60초 기다리지 않고 알림/세션 wiring 즉시 반영.
    unawaited(_tick());
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      unawaited(_tick());
    });
  }

  /// Cancel the ticker and (best-effort) close the active session.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _timer?.cancel();
    _timer = null;
    if (_activeSessionId != null) {
      await ref
          .read(sessionRepositoryProvider)
          .endSession(_activeSessionId!, DateTime.now());
      _activeSessionId = null;
      _activeScheduleId = null;
    }
    unawaited(_safe(_api.stopScheduleNotification));
  }

  /// Native call wrapper — 권한 미허용/플랫폼 channel 미준비 등은 swallow.
  Future<void> _safe(Future<void> Function() fn) async {
    try {
      await fn();
    } on Exception {
      // ignored
    }
  }

  Future<void> _tick() async {
    if (!_started) return;
    final userId = ref.read(authProvider).value?.id ?? 'local';
    final scheduleRepo = ref.read(scheduleRepositoryProvider);
    final all = await scheduleRepo.watchAllActive(userId).first;
    final now = DateTime.now();
    final current = findCurrentActiveSchedule(all, now);

    final sessionRepo = ref.read(sessionRepositoryProvider);

    // Schedule changed (or ended) → close prior session before opening
    // a new one.
    if (_activeScheduleId != null &&
        (current == null || current.id != _activeScheduleId)) {
      if (_activeSessionId != null) {
        await sessionRepo.endSession(_activeSessionId!, now);
      }
      _activeSessionId = null;
      _activeScheduleId = null;
      // 알림 정리 — 다음 분기에서 새 일정이 시작되면 다시 표시.
      unawaited(_safe(_api.stopScheduleNotification));
    }

    // No schedule running → just rotate the poll window and exit.
    if (current == null) {
      _lastPollMs = now.millisecondsSinceEpoch;
      return;
    }

    // Open a session lazily on first tick within the schedule window.
    _activeSessionId ??= await sessionRepo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: current.id,
      startTime: current.startTime ?? now,
      plannedDurationMin: _plannedMinutes(current),
    );
    _activeScheduleId = current.id;

    // Sticky 알림 갱신 — USB 알림 패턴, 사용자가 swipe 로 못 지움.
    final subtitle = _notificationSubtitle(current, now);
    unawaited(
      _safe(() => _api.updateScheduleNotification(current.title, subtitle)),
    );

    // Sample usage for the elapsed window.
    final api = ref.read(usageApiProvider);
    final fromMs = _lastPollMs;
    final toMs = now.millisecondsSinceEpoch;
    var blacklistMs = 0;
    try {
      final usage = await api.queryUsageStats(fromMs, toMs);
      for (final entry in usage) {
        if (entry.packageName == _selfPackage) continue;
        blacklistMs += entry.totalTimeInForeground;
      }
    } on Exception {
      // 권한 미허용 등은 무시 — 다음 tick 에서 재시도.
    }
    _lastPollMs = toMs;

    final phoneInUse = blacklistMs >= _useThresholdMs;
    await sessionRepo.appendUsage(
      sessionId: _activeSessionId!,
      focusedMinDelta: phoneInUse ? 0 : 1,
      blacklistMinDelta: phoneInUse ? 1 : 0,
    );
  }

  int _plannedMinutes(Schedule s) {
    final start = s.startTime;
    final end = s.endTime;
    if (start == null || end == null) return 0;
    return end.difference(start).inMinutes;
  }

  /// 알림 본문 텍스트 — "16:19 까지 (25분 남음)" 형태.
  String _notificationSubtitle(Schedule s, DateTime now) {
    final end = s.endTime;
    if (end == null) return '진행 중';
    final remaining = end.difference(now).inMinutes;
    final hh = end.hour.toString().padLeft(2, '0');
    final mm = end.minute.toString().padLeft(2, '0');
    if (remaining <= 0) return '$hh:$mm 까지';
    return '$hh:$mm 까지 ($remaining분 남음)';
  }
}

/// Provides a singleton [ScheduleSessionTrigger]. Lifecycle is bound to
/// [RoutinemonApp.build] (mirrors [disturbanceControllerProvider]).
final scheduleSessionTriggerProvider = Provider<ScheduleSessionTrigger>(
  (ref) => ScheduleSessionTrigger(ref: ref),
);

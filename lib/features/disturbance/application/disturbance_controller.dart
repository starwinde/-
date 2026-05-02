import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/core/native/disturbance_api.g.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
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

  Timer? _periodicLockTimer;
  Timer? _periodicVibrateTimer;
  bool _started = false;
  bool _serviceRunning = false;

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

    final level = DisturbanceLevel.fromInt(schedule.disruptionIntensity);
    final action = _intervention.onActiveUsage(DateTime.now(), level);
    debugPrint(
        '[Disturbance] level=$level action=$action vibrate=${action?.vibrateMs} launchHome=${action?.launchHome}');
    if (action == null) return;

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

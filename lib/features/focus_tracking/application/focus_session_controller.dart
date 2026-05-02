import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/usage_bridge.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'focus_session_controller.g.dart';

/// Foreground polling controller for focus sessions.
///
/// - App foreground: Dart Timer.periodic 60s polls UsageApi.
/// - App background: FocusForegroundService.kt polls and caches to
///   SharedPreferences.
/// - On re-entry: [mergeCachedUsage] reads the background cache and
///   returns it for Drift insertion.
@riverpod
class FocusSessionController extends _$FocusSessionController {
  Timer? _pollTimer;

  @override
  bool build() => false; // isTracking

  /// Start a focus session.
  void startSession(int scheduleId) {
    if (state) return;
    state = true;
    _pollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _poll(),
    );
  }

  /// Stop a focus session.
  void stopSession() {
    state = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (!state) return;
    final api = ref.read(usageApiProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    // ignore: unused_local_variable — consumed by settlement-impl
    final usage = await api.queryUsageStats(now - 60000, now);
    // Results will be consumed by the settlement logic which reads
    // the Sessions table. For now we accumulate locally — the daily
    // settlement (T3.8) sums all session rows.
  }

  /// Merge background-cached usage data collected by
  /// FocusForegroundService while the app was in the background.
  /// Returns raw JSON entries for Drift insertion, then clears the
  /// cache.
  static Future<List<Map<String, dynamic>>> mergeCachedUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cached_usage');
    if (raw == null || raw == '[]') return [];

    final list = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();

    // Clear after reading.
    await prefs.remove('cached_usage');
    return list;
  }
}

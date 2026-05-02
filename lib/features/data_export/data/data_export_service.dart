import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'data_export_service.g.dart';

const _monthlyCounterKey = 'data_export_monthly_count';
const _monthlyPeriodKey = 'data_export_monthly_period';

/// Serializes a user's Drift-backed data to JSON and copies it to the
/// system clipboard. Free tier: 1 export per month (tracked in
/// SharedPreferences). Pro bypass is enforced by the caller — this
/// service only exposes the counter primitives.
class DataExportService {
  /// Creates a service backed by the given [AppDatabase].
  DataExportService(this._db);

  final AppDatabase _db;

  /// Builds a JSON-serializable snapshot of all user-owned data for
  /// [userId]. Does not touch the clipboard.
  Future<Map<String, dynamic>> buildSnapshot(String userId) async {
    final schedules = await (_db.select(_db.schedules)
          ..where((s) => s.userId.equals(userId)))
        .get();
    final sessions = await (_db.select(_db.sessions)
          ..where((s) => s.userId.equals(userId)))
        .get();
    final pets = await (_db.select(_db.pets)
          ..where((p) => p.userId.equals(userId)))
        .get();
    final scores = await (_db.select(_db.dailyScores)
          ..where((s) => s.userId.equals(userId)))
        .get();

    return {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'user_id': userId,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'pets': pets.map((p) => p.toJson()).toList(),
      'daily_scores': scores.map((s) => s.toJson()).toList(),
    };
  }

  /// Builds the snapshot and returns pretty-printed JSON text.
  Future<String> exportAsJson(String userId) async {
    final snap = await buildSnapshot(userId);
    return const JsonEncoder.withIndent('  ').convert(snap);
  }

  /// Copies [json] to the system clipboard.
  Future<void> copyToClipboard(String json) async {
    await Clipboard.setData(ClipboardData(text: json));
  }

  /// Returns `true` if the free tier still has export quota for the
  /// current calendar month. [maxPerMonth] defaults to 1 per PRD §2.17.
  Future<bool> hasQuota({int maxPerMonth = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPeriod = _periodKey(DateTime.now());
    final savedPeriod = prefs.getString(_monthlyPeriodKey);
    final count = prefs.getInt(_monthlyCounterKey) ?? 0;
    if (savedPeriod != currentPeriod) {
      await prefs.setString(_monthlyPeriodKey, currentPeriod);
      await prefs.setInt(_monthlyCounterKey, 0);
      return true;
    }
    return count < maxPerMonth;
  }

  /// Increments the monthly quota counter for the current period.
  Future<void> recordUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPeriod = _periodKey(DateTime.now());
    if (prefs.getString(_monthlyPeriodKey) != currentPeriod) {
      await prefs.setString(_monthlyPeriodKey, currentPeriod);
      await prefs.setInt(_monthlyCounterKey, 1);
    } else {
      final count = prefs.getInt(_monthlyCounterKey) ?? 0;
      await prefs.setInt(_monthlyCounterKey, count + 1);
    }
  }

  String _periodKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

/// Provides a shared [DataExportService] backed by the app database.
@riverpod
DataExportService dataExportService(Ref ref) {
  return DataExportService(ref.watch(appDatabaseProvider));
}

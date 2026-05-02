import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mood_repository.g.dart';

/// A single mood check-in at a specific timestamp.
///
/// Multiple entries per calendar day are allowed (PRD §2.19 extension).
@immutable
class MoodEntry {
  /// Creates a mood entry at [timestamp] with mood value [mood] (1..5).
  const MoodEntry({required this.timestamp, required this.mood});

  /// Decodes a [MoodEntry] from the compact JSON form `{t: iso8601, v: int}`.
  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        timestamp: DateTime.parse(json['t'] as String),
        mood: json['v'] as int,
      );

  /// Exact wall-clock timestamp of the check-in.
  final DateTime timestamp;

  /// Mood value in the 1..5 scale (PRD §2.19).
  final int mood;

  /// Serializes to the compact JSON form `{t: iso8601, v: int}`.
  Map<String, dynamic> toJson() => {
        't': timestamp.toIso8601String(),
        'v': mood,
      };

  @override
  bool operator ==(Object other) =>
      other is MoodEntry &&
      other.timestamp == timestamp &&
      other.mood == mood;

  @override
  int get hashCode => Object.hash(timestamp, mood);

  @override
  String toString() => 'MoodEntry(t=$timestamp, v=$mood)';
}

/// Mood storage via SharedPreferences.
///
/// Storage format:
/// - New: `moodEntries_YYYY-MM-DD` → JSON array of `{t: iso8601, v: int}`.
/// - Legacy (read-only): `mood_YYYY-MM-DD` → int 1..5.
///
/// PRD §2.19: daily 1~5 emoji, no game effect (AI input only),
/// missing day defaults to neutral (3). Multiple check-ins per day permitted.
class MoodRepository {
  static const _entriesPrefix = 'moodEntries_';
  static const _legacyPrefix = 'mood_';

  /// Neutral mood value used when a day has no entry (PRD §2.19).
  static const neutral = 3;

  /// Minimum accepted mood value (inclusive).
  static const minValue = 1;

  /// Maximum accepted mood value (inclusive).
  static const maxValue = 5;

  /// Adds a mood entry at [timestamp]. Multiple entries per day allowed.
  ///
  /// Writes to `moodEntries_YYYY-MM-DD` only. A legacy `mood_YYYY-MM-DD`
  /// int value for the same day (if any) is not merged into the write —
  /// it remains readable via [getMoodsForDate] only when the new-format
  /// key is absent.
  Future<void> addMoodEntry(DateTime timestamp, int mood) async {
    if (mood < minValue || mood > maxValue) {
      throw ArgumentError('mood must be in [$minValue..$maxValue], got $mood');
    }
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _dateKey(timestamp);
    final existing = _readNewFormatOnly(prefs, dateKey)
      ..add(MoodEntry(timestamp: timestamp, mood: mood))
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final encoded =
        jsonEncode(existing.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_entriesPrefix + dateKey, encoded);
  }

  /// Returns all mood entries recorded on [date] (local calendar day),
  /// sorted ascending by timestamp. When only a legacy int entry exists
  /// for [date], it is surfaced as a single virtual entry at noon.
  Future<List<MoodEntry>> getMoodsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return _readEntriesForKey(prefs, _dateKey(date));
  }

  /// Returns the latest mood value recorded on [date], or `null` if none.
  Future<int?> getLatestMoodForDate(DateTime date) async {
    final entries = await getMoodsForDate(date);
    if (entries.isEmpty) return null;
    return entries.last.mood;
  }

  /// Returns the arithmetic mean mood on [date] as a double 1.0..5.0,
  /// or `null` if no entries.
  Future<double?> getAverageMoodForDate(DateTime date) async {
    final entries = await getMoodsForDate(date);
    if (entries.isEmpty) return null;
    final sum = entries.fold<int>(0, (a, e) => a + e.mood);
    return sum / entries.length;
  }

  /// Returns the average mood (rounded) or [neutral] (3) when no entries.
  /// Use for AI report input (PRD §2.19).
  Future<int> getMoodOrNeutral(DateTime date) async {
    final avg = await getAverageMoodForDate(date);
    return avg?.round() ?? neutral;
  }

  /// Returns a date-keyed map of mood entries overlapping [from]..[to]
  /// (both inclusive, local calendar days). Entries within each date are
  /// sorted ascending. Dates with no entries are omitted.
  Future<Map<String, List<MoodEntry>>> getMoodsInRange(
      DateTime from, DateTime to) async {
    final result = <String, List<MoodEntry>>{};
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      final list = await getMoodsForDate(cursor);
      if (list.isNotEmpty) {
        result[_dateKey(cursor)] = list;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return result;
  }

  /// Backward-compatible single-day write. Appends one entry at the
  /// current time-of-day on [date] so it remains visible in the new
  /// history format.
  @Deprecated('Use addMoodEntry(DateTime.now(), mood) instead')
  Future<void> setMood(DateTime date, int mood) async {
    final now = DateTime.now();
    final ts = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
    );
    await addMoodEntry(ts, mood);
  }

  /// Backward-compatible single-day read (latest wins).
  /// Returns `null` when no entries exist.
  @Deprecated('Use getLatestMoodForDate or getAverageMoodForDate')
  Future<int?> getMood(DateTime date) async {
    return getLatestMoodForDate(date);
  }

  /// Returns every recorded day (yyyy-mm-dd → latest mood).
  /// Scans both new (`moodEntries_`) and legacy (`mood_`) prefixes.
  /// If both keys exist for the same date, the new-format latest wins.
  Future<Map<String, int>> getAllMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, int>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_entriesPrefix)) {
        final dateKey = key.substring(_entriesPrefix.length);
        final list = await _readEntriesForKey(prefs, dateKey);
        if (list.isNotEmpty) {
          result[dateKey] = list.last.mood;
        }
      } else if (key.startsWith(_legacyPrefix)) {
        final dateKey = key.substring(_legacyPrefix.length);
        if (!result.containsKey(dateKey)) {
          final v = prefs.getInt(key);
          if (v != null) result[dateKey] = v;
        }
      }
    }
    return result;
  }

  /// Clears all mood data (both new and legacy keys).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(_entriesPrefix) || key.startsWith(_legacyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  Future<List<MoodEntry>> _readEntriesForKey(
      SharedPreferences prefs, String dateKey) async {
    final newFormat = _readNewFormatOnly(prefs, dateKey);
    if (newFormat.isNotEmpty) return newFormat;
    final legacy = prefs.getInt(_legacyPrefix + dateKey);
    if (legacy != null) {
      final date = DateTime.parse('$dateKey 12:00:00');
      return <MoodEntry>[MoodEntry(timestamp: date, mood: legacy)];
    }
    return <MoodEntry>[];
  }

  /// Reads only the new-format (`moodEntries_`) key. Returns a fresh
  /// growable list (empty when the key is absent or malformed).
  List<MoodEntry> _readNewFormatOnly(
      SharedPreferences prefs, String dateKey) {
    final raw = prefs.getString(_entriesPrefix + dateKey);
    if (raw == null) return <MoodEntry>[];
    try {
      final decoded = jsonDecode(raw) as List;
      final list = decoded
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: true)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    } on FormatException catch (_) {
      return <MoodEntry>[];
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Provides the singleton [MoodRepository].
@riverpod
MoodRepository moodRepository(Ref ref) => MoodRepository();

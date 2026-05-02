// These tests intentionally exercise deprecated backward-compat APIs
// (setMood, getMood) to prove legacy behavior still works. The new
// callers should use addMoodEntry / getLatestMoodForDate.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/mood/data/mood_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MoodRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = MoodRepository();
  });

  test('getMood returns null when not recorded', () async {
    expect(await repo.getMood(DateTime.utc(2026, 4, 19)), isNull);
  });

  test('getMoodOrNeutral returns 3 when missing', () async {
    expect(
      await repo.getMoodOrNeutral(DateTime.utc(2026, 4, 19)),
      MoodRepository.neutral,
    );
  });

  test('setMood persists value', () async {
    final date = DateTime.utc(2026, 4, 19);
    await repo.setMood(date, 4);
    expect(await repo.getMood(date), 4);
  });

  test('addMoodEntry rejects out-of-range values', () async {
    expect(() => repo.addMoodEntry(DateTime.now(), 0), throwsArgumentError);
    expect(() => repo.addMoodEntry(DateTime.now(), 6), throwsArgumentError);
    expect(() => repo.addMoodEntry(DateTime.now(), -1), throwsArgumentError);
  });

  test('getAllMoods returns every recorded day', () async {
    await repo.addMoodEntry(DateTime.utc(2026, 4, 18, 10), 2);
    await repo.addMoodEntry(DateTime.utc(2026, 4, 19, 11), 5);
    final all = await repo.getAllMoods();
    expect(all['2026-04-18'], 2);
    expect(all['2026-04-19'], 5);
    expect(all.length, 2);
  });

  test('addMoodEntry stores multiple entries per day', () async {
    final d = DateTime.utc(2026, 4, 19);
    await repo.addMoodEntry(d.add(const Duration(hours: 8)), 2);
    await repo.addMoodEntry(d.add(const Duration(hours: 13)), 4);
    await repo.addMoodEntry(d.add(const Duration(hours: 21)), 5);
    final entries = await repo.getMoodsForDate(d);
    expect(entries.length, 3);
    expect(entries.map((e) => e.mood).toList(), [2, 4, 5]);
  });

  test('getMoodsForDate returns entries sorted ascending by timestamp',
      () async {
    final d = DateTime.utc(2026, 4, 19);
    // Insert out of order
    await repo.addMoodEntry(d.add(const Duration(hours: 21)), 5);
    await repo.addMoodEntry(d.add(const Duration(hours: 8)), 2);
    await repo.addMoodEntry(d.add(const Duration(hours: 13)), 4);
    final entries = await repo.getMoodsForDate(d);
    expect(entries.length, 3);
    for (var i = 1; i < entries.length; i++) {
      expect(
        entries[i].timestamp.isAfter(entries[i - 1].timestamp),
        isTrue,
        reason: 'entries must be sorted ascending',
      );
    }
    expect(entries.map((e) => e.mood).toList(), [2, 4, 5]);
  });

  test('getLatestMoodForDate returns last entry of the day', () async {
    final d = DateTime.utc(2026, 4, 19);
    await repo.addMoodEntry(d.add(const Duration(hours: 8)), 2);
    await repo.addMoodEntry(d.add(const Duration(hours: 21)), 5);
    expect(await repo.getLatestMoodForDate(d), 5);
    expect(await repo.getLatestMoodForDate(DateTime.utc(2026, 4, 20)), isNull);
  });

  test('getAverageMoodForDate returns arithmetic mean', () async {
    final d = DateTime.utc(2026, 4, 19);
    await repo.addMoodEntry(d.add(const Duration(hours: 8)), 2);
    await repo.addMoodEntry(d.add(const Duration(hours: 13)), 4);
    await repo.addMoodEntry(d.add(const Duration(hours: 21)), 3);
    final avg = await repo.getAverageMoodForDate(d);
    expect(avg, closeTo(3.0, 1e-9));
    expect(
      await repo.getAverageMoodForDate(DateTime.utc(2026, 4, 20)),
      isNull,
    );
  });

  test('getMoodsInRange returns entries across 3 days', () async {
    await repo.addMoodEntry(DateTime.utc(2026, 4, 17, 9), 2);
    await repo.addMoodEntry(DateTime.utc(2026, 4, 18, 10), 3);
    await repo.addMoodEntry(DateTime.utc(2026, 4, 18, 20), 4);
    await repo.addMoodEntry(DateTime.utc(2026, 4, 19, 11), 5);
    final range = await repo.getMoodsInRange(
      DateTime.utc(2026, 4, 17),
      DateTime.utc(2026, 4, 19),
    );
    expect(range.keys.toSet(), {'2026-04-17', '2026-04-18', '2026-04-19'});
    expect(range['2026-04-17']!.length, 1);
    expect(range['2026-04-18']!.length, 2);
    expect(range['2026-04-19']!.length, 1);
    expect(range['2026-04-18']!.map((e) => e.mood).toList(), [3, 4]);
  });

  test('legacy int key is read as single noon entry (backward compat)',
      () async {
    // Seed legacy-only data directly.
    SharedPreferences.setMockInitialValues({
      'mood_2026-04-15': 4,
    });
    repo = MoodRepository();
    final entries = await repo.getMoodsForDate(DateTime.utc(2026, 4, 15));
    expect(entries.length, 1);
    expect(entries.first.mood, 4);
    expect(entries.first.timestamp.hour, 12);
    // getLatestMoodForDate / getAverage should also surface legacy.
    expect(
      await repo.getLatestMoodForDate(DateTime.utc(2026, 4, 15)),
      4,
    );
    expect(
      await repo.getAverageMoodForDate(DateTime.utc(2026, 4, 15)),
      closeTo(4.0, 1e-9),
    );
    // getAllMoods includes legacy-only dates.
    final all = await repo.getAllMoods();
    expect(all['2026-04-15'], 4);
  });

  test(
      'addMoodEntry writes to new key when legacy key exists for same date '
      '(legacy not merged into new write)', () async {
    // Pre-populate legacy int for 2026-04-15.
    SharedPreferences.setMockInitialValues({
      'mood_2026-04-15': 4,
    });
    repo = MoodRepository();
    // New write for same date.
    await repo.addMoodEntry(DateTime.utc(2026, 4, 15, 20), 2);
    // New-format read wins (legacy NOT merged into new JSON array).
    final entries = await repo.getMoodsForDate(DateTime.utc(2026, 4, 15));
    expect(entries.length, 1);
    expect(entries.first.mood, 2);
    expect(entries.first.timestamp.hour, 20);
    // Verify raw storage: new key holds only the newly added entry.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('moodEntries_2026-04-15');
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as List;
    expect(decoded.length, 1);
    expect((decoded.first as Map)['v'], 2);
    // Legacy key is untouched.
    expect(prefs.getInt('mood_2026-04-15'), 4);
  });
}

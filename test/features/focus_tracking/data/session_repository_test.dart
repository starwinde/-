import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/focus_tracking/data/session_repository.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;
  const userId = 'test-user';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionRepository(db);
  });

  tearDown(() => db.close());

  test('getOrCreateActiveSession creates one and reuses it', () async {
    final start = DateTime(2026, 5, 5, 9);
    final id1 = await repo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: 1,
      startTime: start,
      plannedDurationMin: 60,
    );
    final id2 = await repo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: 1,
      startTime: start,
      plannedDurationMin: 60,
    );
    expect(id1, id2);

    final outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(1)); // only insert produced an outbox row
  });

  test('appendUsage increments focus + blacklist counters', () async {
    final id = await repo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: 1,
      startTime: DateTime(2026, 5, 5, 9),
      plannedDurationMin: 60,
    );
    await repo.appendUsage(
      sessionId: id,
      focusedMinDelta: 5,
      blacklistMinDelta: 0,
    );
    await repo.appendUsage(
      sessionId: id,
      focusedMinDelta: 0,
      blacklistMinDelta: 2,
    );
    final row = await (db.select(db.sessions)..where((s) => s.id.equals(id)))
        .getSingle();
    expect(row.actualFocusMin, 5);
    expect(row.blacklistUsageMin, 2);
  });

  test('endSession sets endTime + computes ratio + grade', () async {
    final id = await repo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: 1,
      startTime: DateTime(2026, 5, 5, 9),
      plannedDurationMin: 60,
    );
    await repo.appendUsage(
      sessionId: id,
      focusedMinDelta: 50,
      blacklistMinDelta: 10,
    );
    final endAt = DateTime(2026, 5, 5, 10);
    await repo.endSession(id, endAt);

    final row = await (db.select(db.sessions)..where((s) => s.id.equals(id)))
        .getSingle();
    expect(row.endTime, endAt);
    expect(row.focusRatio, closeTo(50 / 60, 0.001));
    expect(row.isActive, false);
    // 50/60 ≈ 0.833 → B grade (>= 0.70 but < 0.85)
    expect(row.grade, 'b');
  });

  test('getSessionsForDate returns only sessions started that day', () async {
    final today = DateTime(2026, 5, 5);
    final yesterday = DateTime(2026, 5, 4);
    await repo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: 1,
      startTime: today.add(const Duration(hours: 9)),
      plannedDurationMin: 60,
    );
    await repo.getOrCreateActiveSession(
      userId: userId,
      scheduleId: 2,
      startTime: yesterday.add(const Duration(hours: 9)),
      plannedDurationMin: 60,
    );
    final list = await repo.getSessionsForDate(userId, today);
    expect(list, hasLength(1));
    expect(list.first.scheduleId, 1);
  });
}

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/focus_tracking/application/settlement_orchestrator.dart';
import 'package:routinemon/features/focus_tracking/data/session_repository.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';

void main() {
  late AppDatabase db;
  late SessionRepository sessionRepo;
  late PetRepository petRepo;
  late SettlementOrchestrator orch;
  const userId = 'tester';

  Future<int> seedPet({int hp = 100, int xp = 0, int level = 1}) async {
    return db.into(db.pets).insert(
          PetsCompanion.insert(
            userId: userId,
            species: 'bird',
            name: 'birdie',
            hp: Value(hp),
            xp: Value(xp),
            level: Value(level),
          ),
        );
  }

  Future<int> seedSession({
    required DateTime start,
    required int plannedMin,
    required int focusedMin,
    required int blacklistMin,
    int scheduleId = 1,
  }) async {
    final id = await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            userId: userId,
            scheduleId: Value(scheduleId),
            startTime: start,
            plannedDurationMin: Value(plannedMin),
            actualFocusMin: Value(focusedMin),
            blacklistUsageMin: Value(blacklistMin),
          ),
        );
    return id;
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sessionRepo = SessionRepository(db);
    petRepo = PetRepository(db);
    orch = SettlementOrchestrator(
      db: db,
      sessionRepo: sessionRepo,
      petRepo: petRepo,
    );
  });

  tearDown(() => db.close());

  test('returns null when no pet exists', () async {
    final result = await orch.runForDate(
      userId: userId,
      date: DateTime(2026, 5, 5),
    );
    expect(result, null);
  });

  test('returns null and is no-op when day has no scheduled focus', () async {
    final petId = await seedPet();
    final result = await orch.runForDate(
      userId: userId,
      date: DateTime(2026, 5, 5),
    );
    expect(result, null);
    final pet = await (db.select(db.pets)..where((p) => p.id.equals(petId)))
        .getSingle();
    expect(pet.hp, 100, reason: 'no schedules → HP unchanged');
  });

  test('D-grade day deducts HP and inserts daily_score row', () async {
    final petId = await seedPet();
    final today = DateTime(2026, 5, 5);
    // 60min planned, 10min focused → ratio 0.167 → D
    await seedSession(
      start: today.add(const Duration(hours: 9)),
      plannedMin: 60,
      focusedMin: 10,
      blacklistMin: 50,
    );

    final result = await orch.runForDate(userId: userId, date: today);
    expect(result, isNotNull);
    expect(result!.grade.name, 'd');

    final pet = await (db.select(db.pets)..where((p) => p.id.equals(petId)))
        .getSingle();
    expect(pet.hp, lessThan(100), reason: 'D grade deducts HP');

    final scores = await db.select(db.dailyScores).get();
    expect(scores, hasLength(1));
    expect(scores.first.grade, 'd');
    expect(scores.first.totalFocusMinutes, 10);
    expect(scores.first.totalBlacklistMinutes, 50);
  });

  test('S-grade day awards XP and HP', () async {
    final petId = await seedPet(hp: 80);
    final today = DateTime(2026, 5, 5);
    // 60min planned, 60min focused → ratio 1.0 → S
    await seedSession(
      start: today.add(const Duration(hours: 9)),
      plannedMin: 60,
      focusedMin: 60,
      blacklistMin: 0,
    );

    final result = await orch.runForDate(userId: userId, date: today);
    expect(result!.grade.name, 's');

    final pet = await (db.select(db.pets)..where((p) => p.id.equals(petId)))
        .getSingle();
    expect(pet.hp, greaterThan(80), reason: 'S grade restores HP');
    expect(pet.xp, greaterThan(0));
  });

  test('idempotent: same day twice replaces daily_score', () async {
    await seedPet();
    final today = DateTime(2026, 5, 5);
    await seedSession(
      start: today.add(const Duration(hours: 9)),
      plannedMin: 60,
      focusedMin: 30,
      blacklistMin: 30,
    );

    await orch.runForDate(userId: userId, date: today);
    await orch.runForDate(userId: userId, date: today);

    final scores = await db.select(db.dailyScores).get();
    expect(scores, hasLength(1),
        reason: '두 번 정산해도 daily_scores 행은 1개만 유지');
  });
}

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/pet/application/pet_interaction_service.dart';
import 'package:routinemon/features/pet/data/pet_interaction_repository.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';

void main() {
  late AppDatabase db;
  late PetRepository petRepo;
  late PetInteractionRepository interactionRepo;
  late PetInteractionService service;
  const userId = 'user-1';

  Future<int> seedPet({int hp = 50, int xp = 0, int level = 1}) {
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

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    petRepo = PetRepository(db);
    interactionRepo = PetInteractionRepository(db);
    service = PetInteractionService(
      petRepo: petRepo,
      interactionRepo: interactionRepo,
    );
  });

  tearDown(() => db.close());

  test('feed: HP +5 적용', () async {
    final petId = await seedPet(hp: 50, xp: 0);
    final result = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
    );
    expect(result.success, true);
    expect(result.hpDelta, 5);
    expect(result.newHp, 55);
    expect(result.xpDelta, 0);
  });

  test('feed: 이미 98 HP 면 cap 100 + overflow 2:1 → XP', () async {
    // 98 + 5 = 103, cap 100, overflow 3 → XP +1 (3 // 2)
    final petId = await seedPet(hp: 98, xp: 0);
    final r = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
    );
    expect(r.success, true);
    expect(r.newHp, 100);
    expect(r.xpDelta, 1, reason: 'overflow 3 // 2 = 1 XP');
  });

  test('play: XP +5, HP 무변화', () async {
    final petId = await seedPet(hp: 50, xp: 0);
    final result = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.play,
    );
    expect(result.success, true);
    expect(result.xpDelta, 5);
    expect(result.newXp, 5);
    expect(result.hpDelta, 0);
    expect(result.newHp, 50);
  });

  test('pet (쓰다듬기): HP/XP 변경 없음, intimacy 누적만', () async {
    final petId = await seedPet(hp: 50, xp: 0);
    final result = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.pet,
    );
    expect(result.success, true);
    expect(result.hpDelta, 0);
    expect(result.xpDelta, 0);

    final intimacy = await interactionRepo.countAllByAction(
      petId: petId,
      action: PetActionType.pet,
    );
    expect(intimacy, 1);
  });

  test('일일 한도 — feed 2회째 차단', () async {
    final petId = await seedPet(hp: 50);
    final r1 = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
    );
    expect(r1.success, true);
    final r2 = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
    );
    expect(r2.success, false);
    expect(r2.dailyLimit, 1);

    // HP 한 번만 적용됐는지
    final pet = await petRepo.getActivePet(userId);
    expect(pet!.hp, 55);
  });

  test('일일 한도 — pet (쓰다듬기) 4회째 차단', () async {
    final petId = await seedPet();
    for (var i = 0; i < 3; i++) {
      final r = await service.apply(
        petId: petId,
        userId: userId,
        action: PetActionType.pet,
      );
      expect(r.success, true, reason: '${i + 1}회는 허용');
    }
    final r4 = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.pet,
    );
    expect(r4.success, false);
    expect(r4.dailyLimit, 3);
  });

  test('자정 reset — 어제 적용분은 오늘 한도에 영향 없음', () async {
    final petId = await seedPet(hp: 50);
    // 어제 feed 1회 (한도 사용)
    await interactionRepo.insert(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
      performedAt: DateTime(2026, 5, 4, 23, 30),
    );
    // 오늘 feed 시도
    final today = DateTime(2026, 5, 5, 9);
    final r = await service.apply(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
      now: today,
    );
    expect(r.success, true, reason: '어제 사용분은 자정 후 reset');
  });
}

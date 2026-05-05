import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/pet/data/pet_interaction_repository.dart';

void main() {
  late AppDatabase db;
  late PetInteractionRepository repo;
  const userId = 'user-1';
  const petId = 1;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PetInteractionRepository(db);
    await db.into(db.pets).insert(
          PetsCompanion.insert(
            userId: userId,
            species: 'bird',
            name: 'birdie',
          ),
        );
  });

  tearDown(() => db.close());

  test('insert: outbox row created with payload', () async {
    final id = await repo.insert(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
    );
    expect(id, greaterThan(0));
    final outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(1));
    expect(outbox.first.targetTable, 'pet_interactions');
    expect(outbox.first.operation, 'insert');
    expect(outbox.first.payload, contains('"action_type":"feed"'));
  });

  test('countTodayByAction: counts only today and only matching action',
      () async {
    final today = DateTime(2026, 5, 5, 14);
    final yesterday = DateTime(2026, 5, 4, 14);
    await repo.insert(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
      performedAt: today,
    );
    await repo.insert(
      petId: petId,
      userId: userId,
      action: PetActionType.pet,
      performedAt: today,
    );
    await repo.insert(
      petId: petId,
      userId: userId,
      action: PetActionType.feed,
      performedAt: yesterday,
    );

    expect(
      await repo.countTodayByAction(
        petId: petId,
        action: PetActionType.feed,
        now: today,
      ),
      1,
      reason: '오늘 feed 1건 — 어제 feed 와 오늘 pet 은 제외',
    );
    expect(
      await repo.countTodayByAction(
        petId: petId,
        action: PetActionType.play,
        now: today,
      ),
      0,
    );
  });

  test('countAllByAction: lifetime intimacy via pet action count', () async {
    final dates = [
      DateTime(2026, 5, 1),
      DateTime(2026, 5, 3),
      DateTime(2026, 5, 5),
    ];
    for (final d in dates) {
      await repo.insert(
        petId: petId,
        userId: userId,
        action: PetActionType.pet,
        performedAt: d,
      );
    }
    expect(
      await repo.countAllByAction(petId: petId, action: PetActionType.pet),
      3,
    );
  });
}

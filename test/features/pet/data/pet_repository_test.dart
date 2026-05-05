import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';

void main() {
  late AppDatabase db;
  late PetRepository repo;
  const userId = 'test-user-id';

  Future<int> insertBirdLv1() async {
    return db.into(db.pets).insert(
          PetsCompanion.insert(
            userId: userId,
            species: 'bird',
            name: 'tester',
          ),
        );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PetRepository(db);
  });

  tearDown(() => db.close());

  group('PetRepository', () {
    test('watchActivePet emits inserted pet', () async {
      final id = await insertBirdLv1();
      final stream = repo.watchActivePet(userId);
      final pet = await stream.first;
      expect(pet, isNotNull);
      expect(pet!.id, id);
      expect(pet.name, 'tester');
      expect(pet.level, 1);
      expect(pet.xp, 0);
      expect(pet.hp, 100);
    });

    test('watchActivePet emits null when no pet', () async {
      final stream = repo.watchActivePet(userId);
      final pet = await stream.first;
      expect(pet, isNull);
    });

    test('applySettlement updates xp/hp/level + outbox enqueue', () async {
      final id = await insertBirdLv1();

      // Bird Lv1 → Lv2 임계 = 60 XP. 60 XP 적용 시 level = 2 가 되어야 한다.
      await repo.applySettlement(
        petId: id,
        newXp: 60,
        newHp: 95,
        isAlive: true,
      );

      final pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.xp, 60);
      expect(pet.hp, 95);
      expect(pet.level, 2,
          reason: 'birdEvolutionXp[0] = 60 통과 → Lv2 자동 진화');

      final outbox = await db.select(db.outbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.first.targetTable, 'pets');
      expect(outbox.first.operation, 'update');
      expect(outbox.first.rowId, id.toString());
    });

    test('addXp accumulates across multiple thresholds', () async {
      final id = await insertBirdLv1();

      // 60 → Lv2
      await repo.addXp(id, 60);
      var pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.level, 2);
      expect(pet.xp, 60);

      // +150 → 210 → Lv3
      await repo.addXp(id, 150);
      pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.level, 3);
      expect(pet.xp, 210);

      // +270 → 480 → Lv4
      await repo.addXp(id, 270);
      pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.level, 4);

      // +420 → 900 → Lv5 (max for bird)
      await repo.addXp(id, 420);
      pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.level, 5, reason: '새 5단계 cap 도달');

      // Further xp does not push level past cap
      await repo.addXp(id, 1000);
      pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.level, 5);
    });

    test('applySettlement isAlive=false sets diedAt', () async {
      final id = await insertBirdLv1();
      await repo.applySettlement(
        petId: id,
        newXp: 0,
        newHp: 0,
        isAlive: false,
      );

      final pet = await (db.select(db.pets)..where((p) => p.id.equals(id)))
          .getSingle();
      expect(pet.isAlive, false);
      expect(pet.diedAt, isNotNull);
    });

    test('watchActivePet only returns alive pets, latest first', () async {
      final dead = await insertBirdLv1();
      await repo.applySettlement(
        petId: dead,
        newXp: 0,
        newHp: 0,
        isAlive: false,
      );

      // small delay so createdAt differs (drift uses currentDateAndTime)
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final alive = await db.into(db.pets).insert(
            PetsCompanion.insert(
              userId: userId,
              species: 'dragon',
              name: 'alive',
            ),
          );

      final pet = await repo.watchActivePet(userId).first;
      expect(pet, isNotNull);
      expect(pet!.id, alive);
      expect(pet.species, 'dragon');
    });
  });
}

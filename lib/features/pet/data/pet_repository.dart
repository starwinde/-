import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/pet/domain/level_curve.dart' as level_curve;
import 'package:routinemon/features/pet/domain/pet.dart' as domain;
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

part 'pet_repository.g.dart';

/// Repository for Pet read/update with outbox enqueue (rules.md §3.7).
///
/// Domain logic stays in `lib/features/pet/domain/` — this layer only
/// translates between Drift rows and domain decisions.
class PetRepository {
  PetRepository(this._db);

  final AppDatabase _db;

  /// Watches the most recent alive pet for [userId]. Emits null when none.
  Stream<Pet?> watchActivePet(String userId) {
    return ((_db.select(_db.pets))
          ..where((p) => p.userId.equals(userId) & p.isAlive.equals(true))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Reads the active pet once (no stream).
  Future<Pet?> getActivePet(String userId) {
    return ((_db.select(_db.pets))
          ..where((p) => p.userId.equals(userId) & p.isAlive.equals(true))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Applies a settlement result to the pet row. Recomputes [level] from
  /// [newXp] via [level_curve.checkEvolution] so callers can pass raw xp
  /// without pre-computing the level. Enqueues an outbox row in the same
  /// transaction (rules.md §3.7).
  Future<void> applySettlement({
    required int petId,
    required int newXp,
    required int newHp,
    required bool isAlive,
  }) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.pets)
            ..where((p) => p.id.equals(petId)))
          .getSingle();
      final species = _speciesFromString(row.species);
      final newLevel = level_curve.checkEvolution(species, row.level, newXp);
      await (_db.update(_db.pets)..where((p) => p.id.equals(petId))).write(
        PetsCompanion(
          xp: Value(newXp),
          hp: Value(newHp),
          level: Value(newLevel),
          isAlive: Value(isAlive),
          diedAt: isAlive
              ? const Value.absent()
              : Value(row.diedAt ?? DateTime.now()),
        ),
      );
      await _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              targetTable: 'pets',
              rowId: petId.toString(),
              operation: 'update',
              payload: '{}',
            ),
          );
    });
  }

  /// Adds [delta] xp to the pet, recomputing level. Used by daily settlement
  /// callers and by the dev "+XP" trigger that exercises evolution thresholds.
  Future<void> addXp(int petId, int delta) async {
    final row = await (_db.select(_db.pets)
          ..where((p) => p.id.equals(petId)))
        .getSingle();
    final newXp = (row.xp + delta).clamp(0, 1 << 31);
    await applySettlement(
      petId: petId,
      newXp: newXp,
      newHp: row.hp,
      isAlive: row.isAlive,
    );
  }

  domain.PetSpecies _speciesFromString(String s) => switch (s) {
        'bird' => domain.PetSpecies.bird,
        'dragon' => domain.PetSpecies.dragon,
        'dolphin' => domain.PetSpecies.dolphin,
        _ => domain.PetSpecies.bird,
      };
}

/// Provides the [PetRepository] backed by the app database.
@riverpod
PetRepository petRepository(Ref ref) {
  return PetRepository(ref.watch(appDatabaseProvider));
}

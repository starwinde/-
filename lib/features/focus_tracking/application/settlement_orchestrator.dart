import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/constants/xp_rules.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/focus_tracking/application/daily_settlement.dart';
import 'package:routinemon/features/focus_tracking/data/session_repository.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

part 'settlement_orchestrator.g.dart';

/// Orchestrates the end-of-day settlement: aggregates the day's sessions,
/// runs [DailySettlement.settle], persists a [DailyScores] row, and updates
/// the active pet via [PetRepository.applySettlement] (rules.md §3.7, §3.8).
class SettlementOrchestrator {
  SettlementOrchestrator({
    required AppDatabase db,
    required SessionRepository sessionRepo,
    required PetRepository petRepo,
  })  : _db = db,
        _sessionRepo = sessionRepo,
        _petRepo = petRepo;

  final AppDatabase _db;
  final SessionRepository _sessionRepo;
  final PetRepository _petRepo;

  /// Run settlement for [userId] on the local calendar day of [date].
  /// Returns the produced [SettlementResult], or null when there is no
  /// pet or no scheduled focus minutes for the day (no-op).
  Future<SettlementResult?> runForDate({
    required String userId,
    required DateTime date,
  }) async {
    final pet = await _petRepo.getActivePet(userId);
    if (pet == null) return null;

    final sessions = await _sessionRepo.getSessionsForDate(userId, date);
    final totalPlanned = sessions.fold<int>(
      0,
      (acc, s) => acc + s.plannedDurationMin,
    );
    final totalActual = sessions.fold<int>(
      0,
      (acc, s) => acc + s.actualFocusMin,
    );
    if (totalPlanned == 0) {
      return null; // No scheduled focus → skip settlement.
    }

    final ratio = (totalActual / totalPlanned).clamp(0.0, 1.0);
    final incompleteTasks = await _countIncompleteTasksFor(userId, date);
    final consecutiveD = await _readConsecutiveD(userId, date);
    final species = _speciesFromString(pet.species);

    final result = DailySettlement.settle(
      focusRatio: ratio,
      currentHp: pet.hp,
      currentXp: pet.xp,
      currentLevel: pet.level,
      species: species,
      consecutiveDCount: consecutiveD,
      incompleteTaskCount: incompleteTasks,
      isAlive: pet.isAlive,
    );

    await _insertDailyScore(
      userId: userId,
      date: date,
      ratio: ratio,
      result: result,
      totalActual: totalActual,
      totalBlacklist: sessions.fold<int>(
        0,
        (acc, s) => acc + s.blacklistUsageMin,
      ),
    );

    await _petRepo.applySettlement(
      petId: pet.id,
      newXp: result.newXp,
      newHp: result.newHp,
      isAlive: result.isAlive,
    );

    return result;
  }

  Future<int> _countIncompleteTasksFor(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.schedules)
          ..where(
            (s) =>
                s.userId.equals(userId) &
                s.isTodo.equals(true) &
                s.deletedAt.isNull() &
                s.startTime.isBiggerOrEqualValue(start) &
                s.startTime.isSmallerThanValue(end) &
                s.isCompleted.equals(false),
          ))
        .get();
    return rows.length;
  }

  Future<int> _readConsecutiveD(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final yesterday = start.subtract(const Duration(days: 1));
    final row = await (_db.select(_db.dailyScores)
          ..where((s) =>
              s.userId.equals(userId) &
              s.date.isBiggerOrEqualValue(yesterday) &
              s.date.isSmallerThanValue(start))
          ..orderBy([(s) => OrderingTerm.desc(s.date)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null || row.grade != FocusGrade.d.name) return 0;
    // Daily scores doesn't track consecutiveD directly; treat presence of
    // yesterday's D as +1 streak (caller computes settlement).
    return 1;
  }

  Future<void> _insertDailyScore({
    required String userId,
    required DateTime date,
    required double ratio,
    required SettlementResult result,
    required int totalActual,
    required int totalBlacklist,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    await _db.transaction(() async {
      // Replace any existing daily_scores row for this day (idempotent).
      await (_db.delete(_db.dailyScores)
            ..where((s) =>
                s.userId.equals(userId) & s.date.equals(dayStart)))
          .go();
      final id = await _db.into(_db.dailyScores).insert(
            DailyScoresCompanion.insert(
              userId: userId,
              date: dayStart,
              focusRatio: Value(ratio),
              grade: result.grade.name,
              xpEarned: Value(result.xpEarned),
              hpChange: Value(result.hpChange),
              totalFocusMinutes: Value(totalActual),
              totalBlacklistMinutes: Value(totalBlacklist),
            ),
          );
      await _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              targetTable: 'daily_scores',
              rowId: id.toString(),
              operation: 'insert',
              payload: '{}',
            ),
          );
    });
  }

  PetSpecies _speciesFromString(String s) => switch (s) {
        'bird' => PetSpecies.bird,
        'dragon' => PetSpecies.dragon,
        'dolphin' => PetSpecies.dolphin,
        _ => PetSpecies.bird,
      };
}

/// Provides the [SettlementOrchestrator].
@riverpod
SettlementOrchestrator settlementOrchestrator(Ref ref) {
  return SettlementOrchestrator(
    db: ref.watch(appDatabaseProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
    petRepo: ref.watch(petRepositoryProvider),
  );
}

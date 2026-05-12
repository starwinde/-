import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:routinemon/core/constants/xp_rules.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/focus_tracking/application/daily_settlement.dart';
import 'package:routinemon/features/focus_tracking/data/session_repository.dart';
import 'package:routinemon/features/focus_tracking/domain/realtime_hp_rule.dart';
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

    // rev 35 — 하루 누적 HP 손실(실시간 + 정산) ≤ dailyHpLossCap (10).
    // 실시간 측은 매 -1 감소 시 daily_hp_loss_<date> 키를 +1 한다.
    // 정산 차감액은 (cap - 이미 손실한 양) 안으로 clamp.
    final adjusted = await _capDailyHpLoss(date: date, raw: result);

    await _insertDailyScore(
      userId: userId,
      date: date,
      ratio: ratio,
      result: adjusted,
      totalActual: totalActual,
      totalBlacklist: sessions.fold<int>(
        0,
        (acc, s) => acc + s.blacklistUsageMin,
      ),
    );

    await _petRepo.applySettlement(
      petId: pet.id,
      newXp: adjusted.newXp,
      newHp: adjusted.newHp,
      isAlive: adjusted.isAlive,
    );

    return adjusted;
  }

  /// 정산 결과를 daily HP loss cap 안으로 clamp.
  /// hpChange 가 양수(증가)면 그대로. 음수면 (cap - 이미 손실한 양) 까지만.
  Future<SettlementResult> _capDailyHpLoss({
    required DateTime date,
    required SettlementResult raw,
  }) async {
    if (raw.hpChange >= 0) return raw;
    final prefs = await SharedPreferences.getInstance();
    final key = _dailyHpLossKey(date);
    final lossSoFar = prefs.getInt(key) ?? 0;
    final remaining = XpRules.dailyHpLossCap - lossSoFar;
    if (remaining <= 0) {
      // 이미 cap 도달 → 정산 차감 0.
      final restoredHp = raw.newHp - raw.hpChange; // raw.hpChange < 0
      return SettlementResult(
        grade: raw.grade,
        xpEarned: raw.xpEarned,
        hpChange: 0,
        newHp: restoredHp.clamp(0, XpRules.maxHp),
        newXp: raw.newXp,
        newLevel: raw.newLevel,
        evolved: raw.evolved,
        isAlive: raw.isAlive || restoredHp > 0,
        consecutiveDCount: raw.consecutiveDCount,
        taskPenalty: raw.taskPenalty,
      );
    }
    final rawLoss = -raw.hpChange;
    if (rawLoss <= remaining) {
      // 통째로 적용 가능 — 카운터만 갱신.
      await prefs.setInt(key, lossSoFar + rawLoss);
      return raw;
    }
    // 부분 적용 — clamped 차감으로 변경.
    final cappedChange = -remaining;
    final hpDelta = cappedChange - raw.hpChange; // 양수 (회복 방향)
    final newHp = (raw.newHp + hpDelta).clamp(0, XpRules.maxHp);
    await prefs.setInt(key, XpRules.dailyHpLossCap);
    return SettlementResult(
      grade: raw.grade,
      xpEarned: raw.xpEarned,
      hpChange: cappedChange,
      newHp: newHp,
      newXp: raw.newXp,
      newLevel: raw.newLevel,
      evolved: raw.evolved,
      isAlive: raw.isAlive || newHp > 0,
      consecutiveDCount: raw.consecutiveDCount,
      taskPenalty: raw.taskPenalty,
    );
  }

  String _dailyHpLossKey(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$dailyHpLossKeyPrefix$y-$m-$d';
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

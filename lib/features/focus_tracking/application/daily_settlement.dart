// 일일 정산 로직 — 순수 함수 (rules.md §3.3, §3.8).
// DB 접근은 호출자가 담당.

import 'package:routinemon/core/constants/xp_rules.dart';
import 'package:routinemon/features/focus_tracking/application/xp_calculator.dart'
    as xp_calc;
import 'package:routinemon/features/pet/domain/hp_curve.dart' as hp_curve;
import 'package:routinemon/features/pet/domain/level_curve.dart' as level_curve;
import 'package:routinemon/features/pet/domain/pet.dart';

class DailySettlement {
  const DailySettlement._();

  /// 일일 정산 수행. 순수 함수 (DB 접근은 호출자가 담당).
  static SettlementResult settle({
    required double focusRatio,
    required int currentHp,
    required int currentXp,
    required int currentLevel,
    required PetSpecies species,
    required int consecutiveDCount,
    required int incompleteTaskCount,
    required bool isAlive,
  }) {
    if (!isAlive) return SettlementResult.dead();

    // 1. 등급 판정
    final grade = xp_calc.gradeFromRatio(focusRatio);

    // 2. XP 산출
    final xpEarned = xp_calc.xpForGrade(grade);

    // 3. HP 산출
    int hpChange = xp_calc.hpForGrade(grade);

    // 4. HP 가중 차감 (D 연속)
    int newConsecutiveD = consecutiveDCount;
    if (grade == FocusGrade.d) {
      newConsecutiveD++;
      hpChange = hp_curve.hpDeduction(newConsecutiveD);
    } else if (grade.index <= FocusGrade.b.index) {
      // B 이상이면 리셋
      newConsecutiveD = 0;
    }

    // 5. 할일 미완료 패널티
    final penalty = taskPenalty(incompleteTaskCount);
    hpChange += penalty;

    // 6. HP 적용 (overflow → XP 보너스)
    final hpResult = hp_curve.applyHpChange(currentHp, hpChange);

    // 7. XP 적용
    final totalXp = currentXp + xpEarned + hpResult.overflowXp;

    // 8. 진화 체크
    final newLevel = level_curve.checkEvolution(species, currentLevel, totalXp);
    final evolved = newLevel > currentLevel;

    // 9. 사망 체크
    final alive = !level_curve.shouldDie(hpResult.newHp);

    return SettlementResult(
      grade: grade,
      xpEarned: xpEarned + hpResult.overflowXp,
      hpChange: hpChange,
      newHp: hpResult.newHp,
      newXp: totalXp,
      newLevel: newLevel,
      evolved: evolved,
      isAlive: alive,
      consecutiveDCount: newConsecutiveD,
      taskPenalty: penalty,
    );
  }

  /// 할일 미완료 패널티 계산.
  static int taskPenalty(int incompleteCount) {
    return (incompleteCount * XpRules.incompleteTaskHpPenalty)
        .clamp(XpRules.incompleteTaskDailyMax, 0);
  }
}

class SettlementResult {
  const SettlementResult({
    required this.grade,
    required this.xpEarned,
    required this.hpChange,
    required this.newHp,
    required this.newXp,
    required this.newLevel,
    required this.evolved,
    required this.isAlive,
    required this.consecutiveDCount,
    required this.taskPenalty,
  });

  factory SettlementResult.dead() => const SettlementResult(
        grade: FocusGrade.d,
        xpEarned: 0,
        hpChange: 0,
        newHp: 0,
        newXp: 0,
        newLevel: 0,
        evolved: false,
        isAlive: false,
        consecutiveDCount: 0,
        taskPenalty: 0,
      );

  final FocusGrade grade;
  final int xpEarned;
  final int hpChange;
  final int newHp;
  final int newXp;
  final int newLevel;
  final bool evolved;
  final bool isAlive;
  final int consecutiveDCount;
  final int taskPenalty;
}

// 집중 등급 판정 및 XP/HP 보상 계산.
// 순수 Dart 순수 함수 (rules.md §3.3, §4.4).

import 'package:routinemon/core/constants/xp_rules.dart';

/// [focusRatio](0.0~1.0)를 등급으로 변환.
/// 높은 등급부터 내림차순 비교하여 첫 번째 충족 등급 반환.
FocusGrade gradeFromRatio(double focusRatio) {
  for (final grade in FocusGrade.values) {
    final reward = XpRules.gradeRewards[grade]!;
    if (focusRatio >= reward.minRatio) return grade;
  }
  return FocusGrade.d;
}

/// 등급에 해당하는 XP 반환.
int xpForGrade(FocusGrade grade) => XpRules.gradeRewards[grade]!.xp;

/// 등급에 해당하는 HP 변화량 반환.
int hpForGrade(FocusGrade grade) => XpRules.gradeRewards[grade]!.hp;

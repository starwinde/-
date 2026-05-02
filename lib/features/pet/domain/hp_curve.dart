// HP 가중 차감 및 오버플로우 XP 전환.
// 순수 Dart 순수 함수 (rules.md §3.3, §4.4).

import 'package:routinemon/core/constants/xp_rules.dart';

/// D등급 연속 [consecutiveDCount]일에 따른 HP 차감량.
///
/// 1일차: -10, 2일차: -15, 3일차: -20, ... (+5씩 가중).
/// B등급 이상 1회로 즉시 리셋.
int hpDeduction(int consecutiveDCount) {
  assert(consecutiveDCount >= 1, 'consecutiveDCount must be >= 1');
  return XpRules.hpWeightBaseDeduction +
      XpRules.hpWeightIncrement * (consecutiveDCount - 1);
}

/// HP 변화 적용 결과.
class HpChangeResult {
  /// [newHp]는 cap 적용 후 HP, [overflowXp]는 전환된 XP.
  const HpChangeResult({required this.newHp, required this.overflowXp});

  /// cap 적용 후 HP.
  final int newHp;

  /// 오버플로우 전환 XP.
  final int overflowXp;
}

/// [currentHp]에 [hpDelta]를 적용.
///
/// max 100 cap 적용, 초과분은 2:1 비율로 XP 전환 (내림).
HpChangeResult applyHpChange(int currentHp, int hpDelta) {
  final rawHp = currentHp + hpDelta;
  if (rawHp > XpRules.maxHp) {
    final overflow = rawHp - XpRules.maxHp;
    return HpChangeResult(
      newHp: XpRules.maxHp,
      overflowXp: overflow ~/ XpRules.hpOverflowXpDivisor,
    );
  }
  final clampedHp = rawHp < 0 ? 0 : rawHp;
  return HpChangeResult(newHp: clampedHp, overflowXp: 0);
}

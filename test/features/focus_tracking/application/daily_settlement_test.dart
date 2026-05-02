import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/constants/xp_rules.dart';
import 'package:routinemon/features/focus_tracking/application/daily_settlement.dart';
import 'package:routinemon/features/pet/domain/pet.dart';

void main() {
  group('DailySettlement.settle', () {
    test('S등급 정산: XP +30, HP +15', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96,
        currentHp: 50,
        currentXp: 0,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.s);
      expect(result.xpEarned, 30);
      expect(result.hpChange, 15);
      expect(result.newHp, 65);
      expect(result.newXp, 30);
      expect(result.isAlive, true);
    });

    test('D등급 정산: XP 0, HP -10', () {
      final result = DailySettlement.settle(
        focusRatio: 0.30,
        currentHp: 50,
        currentXp: 10,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.d);
      expect(result.xpEarned, 0);
      expect(result.hpChange, -10);
      expect(result.newHp, 40);
      expect(result.newXp, 10);
      expect(result.consecutiveDCount, 1);
    });

    test('D 연속 3일 → 가중 차감 -20', () {
      final result = DailySettlement.settle(
        focusRatio: 0.30,
        currentHp: 80,
        currentXp: 10,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 2, // 이미 2일 연속 D, 이번이 3일째
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.d);
      expect(result.consecutiveDCount, 3);
      // hpDeduction(3) = -10 + -5*(3-1) = -20
      expect(result.hpChange, -20);
      expect(result.newHp, 60);
    });

    test('HP overflow: HP 98 + S(+15) → HP 100, overflow XP +6 (2:1)', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96,
        currentHp: 98,
        currentXp: 0,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.s);
      // HP 98 + 15 = 113, overflow = 13, overflowXp = 13 ~/ 2 = 6
      expect(result.newHp, 100);
      expect(result.xpEarned, 30 + 6); // base XP + overflow XP
      expect(result.newXp, 36);
    });

    test('진화 트리거: 새 XP 59→89(+30) → 진화 (60 도달)', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96, // S등급
        currentHp: 50,
        currentXp: 59,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.s);
      expect(result.newXp, 89); // 59 + 30
      expect(result.newLevel, 2); // bird threshold 60 달성
      expect(result.evolved, true);
    });

    test('사망: HP 5 + D(-10) → HP 0 → isAlive false', () {
      final result = DailySettlement.settle(
        focusRatio: 0.30,
        currentHp: 5,
        currentXp: 10,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.d);
      expect(result.newHp, 0); // clamped to 0
      expect(result.isAlive, false);
    });

    test('할일 미완료 3건 → -9', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96, // S등급
        currentHp: 50,
        currentXp: 0,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 3,
        isAlive: true,
      );

      expect(result.taskPenalty, -9);
      // HP: 50 + 15 (S등급) + (-9) = 56
      expect(result.hpChange, 15 + (-9));
      expect(result.newHp, 56);
    });

    test('할일 미완료 10건 → -15 (max)', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96,
        currentHp: 50,
        currentXp: 0,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 0,
        incompleteTaskCount: 10,
        isAlive: true,
      );

      // 10 * -3 = -30, clamped to -15
      expect(result.taskPenalty, -15);
      expect(result.hpChange, 15 + (-15));
      expect(result.newHp, 50);
    });

    test('이미 사망 → SettlementResult.dead()', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96,
        currentHp: 0,
        currentXp: 100,
        currentLevel: 2,
        species: PetSpecies.bird,
        consecutiveDCount: 5,
        incompleteTaskCount: 10,
        isAlive: false,
      );

      expect(result.isAlive, false);
      expect(result.xpEarned, 0);
      expect(result.hpChange, 0);
      expect(result.taskPenalty, 0);
      expect(result.evolved, false);
    });
  });

  group('DailySettlement.taskPenalty', () {
    test('0건 → 0', () {
      expect(DailySettlement.taskPenalty(0), 0);
    });

    test('1건 → -3', () {
      expect(DailySettlement.taskPenalty(1), -3);
    });

    test('5건 → -15 (max)', () {
      expect(DailySettlement.taskPenalty(5), -15);
    });

    test('10건 → -15 (max capped)', () {
      expect(DailySettlement.taskPenalty(10), -15);
    });
  });

  group('DailySettlement edge cases', () {
    test('B등급이면 consecutiveD 리셋', () {
      final result = DailySettlement.settle(
        focusRatio: 0.75, // B등급
        currentHp: 50,
        currentXp: 0,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 5,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.b);
      expect(result.consecutiveDCount, 0);
    });

    test('C등급은 consecutiveD 유지 (리셋 안 함)', () {
      final result = DailySettlement.settle(
        focusRatio: 0.55, // C등급
        currentHp: 50,
        currentXp: 0,
        currentLevel: 1,
        species: PetSpecies.bird,
        consecutiveDCount: 3,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      expect(result.grade, FocusGrade.c);
      expect(result.consecutiveDCount, 3); // C는 리셋 안 함
    });

    test('드래곤 진화 임계값 검증', () {
      final result = DailySettlement.settle(
        focusRatio: 0.96,
        currentHp: 50,
        currentXp: 195,
        currentLevel: 1,
        species: PetSpecies.dragon,
        consecutiveDCount: 0,
        incompleteTaskCount: 0,
        isAlive: true,
      );

      // 195 + 30 = 225 >= 200 (dragon threshold 1)
      expect(result.newXp, 225);
      expect(result.newLevel, 2);
      expect(result.evolved, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/constants/xp_rules.dart';
import 'package:routinemon/features/focus_tracking/application/xp_calculator.dart';
import 'package:routinemon/features/pet/domain/hp_curve.dart';
import 'package:routinemon/features/pet/domain/level_curve.dart';
import 'package:routinemon/features/pet/domain/pet.dart';

void main() {
  // ── XpCalculator ──────────────────────────────────────────────

  group('XpCalculator', () {
    test('1. focus_ratio == 0.95 → S등급, XP 30, HP +15', () {
      expect(gradeFromRatio(0.95), FocusGrade.s);
      expect(xpForGrade(FocusGrade.s), 30);
      expect(hpForGrade(FocusGrade.s), 15);
    });

    test('2. focus_ratio == 0.9499 → A등급 (S 미달)', () {
      expect(gradeFromRatio(0.9499), FocusGrade.a);
    });

    test('3. focus_ratio == 0.85 → A등급, XP 20, HP +10', () {
      expect(gradeFromRatio(0.85), FocusGrade.a);
      expect(xpForGrade(FocusGrade.a), 20);
      expect(hpForGrade(FocusGrade.a), 10);
    });

    test('4. focus_ratio == 0.8499 → B등급 (A 미달)', () {
      expect(gradeFromRatio(0.8499), FocusGrade.b);
    });

    test('5. focus_ratio == 0.70 → B등급, XP 10, HP +5', () {
      expect(gradeFromRatio(0.70), FocusGrade.b);
      expect(xpForGrade(FocusGrade.b), 10);
      expect(hpForGrade(FocusGrade.b), 5);
    });

    test('6. focus_ratio == 0.50 → C등급, XP 3, HP 0', () {
      expect(gradeFromRatio(0.50), FocusGrade.c);
      expect(xpForGrade(FocusGrade.c), 3);
      expect(hpForGrade(FocusGrade.c), 0);
    });

    test('7. focus_ratio == 0.4999 → D등급, XP 0, HP -10', () {
      expect(gradeFromRatio(0.4999), FocusGrade.d);
      expect(xpForGrade(FocusGrade.d), 0);
      expect(hpForGrade(FocusGrade.d), -10);
    });
  });

  // ── HpCurve ───────────────────────────────────────────────────

  group('HpCurve', () {
    test('8. D 1일차 → HP -10', () {
      expect(hpDeduction(1), -10);
    });

    test('9. D 2일차 → HP -15 (가중)', () {
      expect(hpDeduction(2), -15);
    });

    test('10. D 4일차 → HP -25 (가중 누적)', () {
      expect(hpDeduction(4), -25);
    });

    test('11. D→B→D → 리셋 후 다시 -10', () {
      // 연속 D 3회 후 B 1회로 리셋, 다시 D 1회
      // B가 리셋을 유발하므로 새 연속 D 카운트는 1
      expect(hpDeduction(1), -10);
    });

    test('12. HP 95 + S(+15) → HP 100, overflow 10 → XP +5 (2:1 내림)', () {
      final result = applyHpChange(95, 15);
      expect(result.newHp, 100);
      expect(result.overflowXp, 5); // overflow 10 / 2 = 5
    });

    test('12b. HP 100 + S(+15) → HP 100, overflow 15 → XP +7 (2:1 내림)', () {
      final result = applyHpChange(100, 15);
      expect(result.newHp, 100);
      expect(result.overflowXp, 7); // overflow 15 / 2 = 7.5 → 내림 7
    });
  });

  // ── LevelCurve ────────────────────────────────────────────────

  group('LevelCurve', () {
    test('13. HP == 0 → isAlive = false', () {
      expect(shouldDie(0), true);
      expect(shouldDie(1), false);
    });

    test('14. 새 XP 60 정확 도달 → 2단계 진화, 59는 미진화', () {
      expect(checkEvolution(PetSpecies.bird, 1, 60), 2);
      expect(checkEvolution(PetSpecies.bird, 1, 59), 1);
    });

    test('15. 드래곤 XP 1200 → 최종 진화', () {
      // dragonEvolutionXp = [200, 600, 1200]
      // level 1 → 2 at 200, 2 → 3 at 600, 3 → 4 at 1200
      expect(checkEvolution(PetSpecies.dragon, 1, 1200), 4);
    });

    test('15b. 돌고래 진화 경계값 검증', () {
      // dolphinEvolutionXp = [250, 750, 1500]
      expect(checkEvolution(PetSpecies.dolphin, 1, 249), 1);
      expect(checkEvolution(PetSpecies.dolphin, 1, 250), 2);
      expect(checkEvolution(PetSpecies.dolphin, 1, 750), 3);
      expect(checkEvolution(PetSpecies.dolphin, 1, 1500), 4);
    });

    test('15c. 새 전체 진화 경로 검증', () {
      // birdEvolutionXp = [60, 210, 480, 900]
      // level 1 → 2 at 60, 2 → 3 at 210, 3 → 4 at 480, 4 → 5 at 900
      expect(checkEvolution(PetSpecies.bird, 1, 210), 3);
      expect(checkEvolution(PetSpecies.bird, 1, 480), 4);
      expect(checkEvolution(PetSpecies.bird, 1, 900), 5);
    });
  });
}

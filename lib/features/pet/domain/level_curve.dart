// 진화(레벨업) 판정 및 사망 판정.
// 순수 Dart 순수 함수 (rules.md §3.3, §4.4).

import 'package:routinemon/core/constants/xp_rules.dart';
import 'package:routinemon/features/pet/domain/pet.dart';

List<int> _evolutionThresholds(PetSpecies species) => switch (species) {
      PetSpecies.bird => XpRules.birdEvolutionXp,
      PetSpecies.dragon => XpRules.dragonEvolutionXp,
      PetSpecies.dolphin => XpRules.dolphinEvolutionXp,
    };

/// 현재 [species]/[currentLevel]/[totalXp]로 도달 가능한 최대 레벨 반환.
///
/// 레벨은 1부터 시작, 진화 임계값 돌파 시 +1.
int checkEvolution(PetSpecies species, int currentLevel, int totalXp) {
  final thresholds = _evolutionThresholds(species);
  var level = 1;
  for (final threshold in thresholds) {
    if (totalXp >= threshold) {
      level++;
    } else {
      break;
    }
  }
  return level;
}

/// HP가 0 이하이면 사망.
bool shouldDie(int hp) => hp <= 0;

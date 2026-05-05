import 'package:flutter/material.dart';

import 'package:routinemon/features/pet/domain/pet.dart';

/// XP 진화 임계값 — 진화 단계 곡선과 진행률 표시용 단일 출처.
///
/// `xp_rules.dart` 의 `XpRules.{birdEvolutionXp, dragonEvolutionXp,
/// dolphinEvolutionXp}` 와 동일한 값을 가진다 — 도메인 의존성을
/// 끌어오지 않기 위해 presentation 측에 사본을 둔다 (rules.md §3.3).
List<int> petEvolutionThresholds(PetSpecies species) => switch (species) {
      PetSpecies.bird => const [60, 210, 480, 900],
      PetSpecies.dragon => const [200, 600, 1200],
      PetSpecies.dolphin => const [250, 750, 1500],
    };

/// XP 진행률 바 — 현재 레벨 → 다음 레벨 임계 사이 진행률을 표시한다.
class PetXpBar extends StatelessWidget {
  const PetXpBar({
    super.key,
    required this.species,
    required this.xp,
    required this.level,
  });

  final PetSpecies species;
  final int xp;
  final int level;

  @override
  Widget build(BuildContext context) {
    final thresholds = petEvolutionThresholds(species);
    final maxLevel = thresholds.length + 1;
    final currentBase = level >= 2 ? thresholds[level - 2] : 0;
    final nextThreshold =
        level <= thresholds.length ? thresholds[level - 1] : null;
    final progress = nextThreshold == null
        ? 1.0
        : ((xp - currentBase) / (nextThreshold - currentBase)).clamp(0.0, 1.0);
    final label = nextThreshold == null
        ? 'XP $xp (MAX Lv$maxLevel)'
        : 'XP $xp / $nextThreshold';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// HP 게이지 — 100 만점 기준, 색상은 위험 단계별로 바뀐다.
class PetHpBar extends StatelessWidget {
  const PetHpBar({super.key, required this.hp});
  final int hp;

  @override
  Widget build(BuildContext context) {
    final progress = (hp / 100).clamp(0.0, 1.0);
    final color = hp >= 70
        ? Colors.green
        : hp >= 30
            ? Colors.orange
            : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 2),
        Text('HP $hp / 100',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart' as db;
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:routinemon/features/pet/presentation/pet_placeholder.dart';
import 'package:routinemon/features/pet/presentation/pet_progress_bars.dart';

/// 홈 대시보드 펫 카드 — 활성 펫의 종/이름/Lv/XP/HP 를 표시한다.
///
/// PetPlaceholder 의 `stage` 인자에 `pet.level` 을 그대로 전달해
/// 진화 단계마다 인벤토리 슬롯명(`그림 C2`, `D3`, `E4` 등)이
/// 자동으로 갱신된다 — 자산 통합 시점에 호출지 변경 0.
class PetCard extends ConsumerWidget {
  const PetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).value?.id ?? 'local';
    final repo = ref.watch(petRepositoryProvider);

    return StreamBuilder<db.Pet?>(
      stream: repo.watchActivePet(userId),
      builder: (context, snapshot) {
        final pet = snapshot.data;
        if (pet == null) {
          return const _NoPetCard();
        }
        return _PetCardContent(pet: pet, repo: repo);
      },
    );
  }
}

class _PetCardContent extends StatelessWidget {
  const _PetCardContent({required this.pet, required this.repo});

  final db.Pet pet;
  final PetRepository repo;

  PetSpecies get _species => switch (pet.species) {
        'bird' => PetSpecies.bird,
        'dragon' => PetSpecies.dragon,
        'dolphin' => PetSpecies.dolphin,
        _ => PetSpecies.bird,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PetPlaceholder(
              species: _species,
              kind: PetPlaceholderKind.stage,
              stage: pet.level,
              size: 80,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lv ${pet.level}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PetXpBar(species: _species, xp: pet.xp, level: pet.level),
                  const SizedBox(height: 6),
                  PetHpBar(hp: pet.hp),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DevAddXpButton(petId: pet.id, repo: repo),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPetCard extends StatelessWidget {
  const _NoPetCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.egg_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '아직 펫이 없어요. 알을 부화해 보세요!',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dev 진화 검증 버튼 — 임계값 통과 시 PetPlaceholder 슬롯명/캡션이
/// 단계별로 갱신되는지 가시 확인용. v1.0 출시 전 제거 또는
/// debug-only 분기로 감출 예정 (별 작업).
class _DevAddXpButton extends StatelessWidget {
  const _DevAddXpButton({required this.petId, required this.repo});
  final int petId;
  final PetRepository repo;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => unawaited(repo.addXp(petId, 60)),
      icon: const Icon(Icons.bolt, size: 16),
      label: const Text('+60 XP (dev)'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
      ),
    );
  }
}

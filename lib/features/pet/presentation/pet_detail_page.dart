import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:routinemon/core/db/app_database.dart' as db;
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/focus_tracking/application/settlement_orchestrator.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:routinemon/features/pet/presentation/pet_placeholder.dart';
import 'package:routinemon/features/pet/presentation/pet_progress_bars.dart';

/// 펫 상세 페이지 — 활성 펫의 종/이름/Lv/XP/HP/태어난 날 + 진화 단계
/// 임계 리스트 (텍스트 placeholder, v1.0 시각 자산 정책 — PRD §2.7).
class PetDetailPage extends ConsumerWidget {
  const PetDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).value?.id ?? 'local';
    final repo = ref.watch(petRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 펫'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: '오늘 정산 실행 (dev)',
            onPressed: () async {
              final orch = ref.read(settlementOrchestratorProvider);
              final messenger = ScaffoldMessenger.of(context);
              final result = await orch.runForDate(
                userId: userId,
                date: DateTime.now(),
              );
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    result == null
                        ? '오늘 정산할 일정·세션이 없습니다.'
                        : '정산 완료 — ${result.grade.name.toUpperCase()}등급 / '
                            'XP +${result.xpEarned} / HP ${result.hpChange >= 0 ? '+' : ''}${result.hpChange}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<db.Pet?>(
        stream: repo.watchActivePet(userId),
        builder: (context, snapshot) {
          final pet = snapshot.data;
          if (pet == null) {
            return const _NoPet();
          }
          return _PetDetailBody(pet: pet);
        },
      ),
    );
  }
}

class _PetDetailBody extends StatelessWidget {
  const _PetDetailBody({required this.pet});
  final db.Pet pet;

  PetSpecies get _species => switch (pet.species) {
        'bird' => PetSpecies.bird,
        'dragon' => PetSpecies.dragon,
        'dolphin' => PetSpecies.dolphin,
        _ => PetSpecies.bird,
      };

  String get _speciesLabel => switch (_species) {
        PetSpecies.bird => '새 (5단계, 빠른 성장)',
        PetSpecies.dragon => '드래곤 (4단계, 중간 성장)',
        PetSpecies.dolphin => '돌고래 (4단계, 느린 성장)',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: PetPlaceholder(
            species: _species,
            kind: PetPlaceholderKind.stage,
            stage: pet.level,
            size: 160,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            pet.name,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv ${pet.level}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        PetXpBar(species: _species, xp: pet.xp, level: pet.level),
        const SizedBox(height: 8),
        PetHpBar(hp: pet.hp),
        const SizedBox(height: 24),
        _SectionTitle('진화 단계'),
        const SizedBox(height: 8),
        _EvolutionStageList(species: _species, currentLevel: pet.level),
        const SizedBox(height: 24),
        _SectionTitle('기본 정보'),
        const SizedBox(height: 8),
        _InfoRow('종', _speciesLabel),
        _InfoRow('태어난 날', _formatDate(pet.createdAt)),
        _InfoRow('현재 XP', '${pet.xp}'),
        _InfoRow('현재 HP', '${pet.hp} / 100'),
        _InfoRow('생존', pet.isAlive ? '생존' : '사망'),
        if (!pet.isAlive && pet.diedAt != null)
          _InfoRow('사망 시각', _formatDate(pet.diedAt!)),
        if (!pet.isAlive && (pet.deathCause ?? '').isNotEmpty)
          _InfoRow('사망 사유', pet.deathCause!),
      ],
    );
  }

  static String _formatDate(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
}

class _NoPet extends StatelessWidget {
  const _NoPet();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          '아직 펫이 없어요.\n홈 화면에서 알을 부화해 보세요!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _EvolutionStageList extends StatelessWidget {
  const _EvolutionStageList({
    required this.species,
    required this.currentLevel,
  });

  final PetSpecies species;
  final int currentLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thresholds = petEvolutionThresholds(species);
    final maxLevel = thresholds.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(maxLevel, (index) {
        final lv = index + 1;
        final isCurrent = lv == currentLevel;
        final reached = lv <= currentLevel;
        final required = lv == 1 ? 0 : thresholds[lv - 2];
        final color = isCurrent
            ? theme.colorScheme.primary
            : reached
                ? theme.colorScheme.outline
                : theme.colorScheme.outlineVariant;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: isCurrent ? 2 : 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  'Lv $lv',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lv == 1 ? '시작 단계' : '누적 XP $required 달성 시',
                  style: theme.textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
              if (isCurrent)
                Icon(Icons.star, size: 18, color: color)
              else if (reached)
                Icon(Icons.check, size: 18, color: color),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:routinemon/features/schedule/application/schedule_providers.dart';

/// Displays soft-deleted schedules with restore/permanent-delete actions.
/// Period limits (free 7d / Pro 60d) deferred to Phase 5 (payment).
class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).value?.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final trashAsync = ref.watch(trashSchedulesProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('휴지통')),
      body: trashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('휴지통이 비어있습니다.'));
          }
          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              return _TrashTile(schedule: schedules[index]);
            },
          );
        },
      ),
    );
  }
}

class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        schedule.title,
        style: const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      subtitle: schedule.deletedAt != null
          ? Text(
              '삭제: ${_formatDate(schedule.deletedAt!)}',
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: '복원',
            onPressed: () {
              unawaited(
                ref
                    .read(scheduleActionsProvider.notifier)
                    .restore(schedule.id),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: '영구 삭제',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('영구 삭제'),
                  content: const Text('이 일정을 영구적으로 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                unawaited(
                  ref
                      .read(scheduleActionsProvider.notifier)
                      .permanentDelete(schedule.id),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/features/schedule/presentation/weekly_grid_view.dart';

/// Main schedule page. Displays the weekly grid (Mon-Sun) as the default view.
///
/// PRD §2.8 rev 12: 주간 기반. `+` FAB → Wizard (기본), AppBar 편집 아이콘 →
/// 수동 추가 (보조).
class SchedulePage extends ConsumerWidget {
  /// Creates the schedule page.
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: '수동 추가',
            onPressed: () => context.push('/schedule/create'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '휴지통',
            onPressed: () => context.push('/trash'),
          ),
        ],
      ),
      body: const WeeklyGridView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/schedule/wizard-v3'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('주간 생성'),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:routinemon/features/schedule/application/schedule_providers.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

/// Weekly schedule grid view. 7 columns (Mon-Sun) on wide screens, collapses
/// to day tabs on narrow screens (< 600px).
class WeeklyGridView extends ConsumerStatefulWidget {
  /// Creates a weekly grid view. Defaults to the current week's Monday.
  const WeeklyGridView({super.key, DateTime? weekStart})
      : _initialWeekStart = weekStart;

  final DateTime? _initialWeekStart;

  /// Returns the Monday of the week containing [date] with time zeroed.
  static DateTime mondayOfWeek(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final daysFromMonday = local.weekday - DateTime.monday;
    return local.subtract(Duration(days: daysFromMonday));
  }

  @override
  ConsumerState<WeeklyGridView> createState() => _WeeklyGridViewState();
}

class _DayBuckets {
  _DayBuckets({required this.timeSlot, required this.dayOnly});
  final List<Schedule> timeSlot;
  final List<Schedule> dayOnly;
}

class _WeeklyGridViewState extends ConsumerState<WeeklyGridView> {
  late DateTime _weekStart;
  final Set<int> _selectedIds = {};

  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  static const _narrowBreakpoint = 600.0;

  bool get _selectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _weekStart = widget._initialWeekStart ??
        WeeklyGridView.mondayOfWeek(DateTime.now());
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedIds.clear);
  }

  Future<void> _confirmDeleteSelected() async {
    final count = _selectedIds.length;
    if (count == 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('선택된 $count개 일정을 휴지통으로 이동할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final ids = _selectedIds.toList();
    await ref
        .read(scheduleActionsProvider.notifier)
        .softDeleteMany(ids);
    if (!mounted) return;
    setState(_selectedIds.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ids.length}개 일정을 휴지통으로 이동했습니다')),
    );
  }

  void _prevWeek() => setState(
        () => _weekStart = _weekStart.subtract(const Duration(days: 7)),
      );

  void _nextWeek() => setState(
        () => _weekStart = _weekStart.add(const Duration(days: 7)),
      );

  List<_DayBuckets> _groupByDay(List<Schedule> all) {
    final weekEnd = _weekStart.add(const Duration(days: 7));
    final buckets = List.generate(
      7,
      (_) => _DayBuckets(timeSlot: [], dayOnly: []),
    );
    for (final s in all) {
      final start = s.startTime;
      if (start == null) continue;
      if (start.isBefore(_weekStart) || !start.isBefore(weekEnd)) continue;
      final index = start.weekday - DateTime.monday;
      if (index < 0 || index > 6) continue;
      final isDayOnly = s.isTodo && start.hour == 0 && start.minute == 0;
      if (isDayOnly) {
        buckets[index].dayOnly.add(s);
      } else {
        buckets[index].timeSlot.add(s);
      }
    }
    for (final b in buckets) {
      b.timeSlot.sort((a, c) => a.startTime!.compareTo(c.startTime!));
      b.dayOnly.sort((a, c) => a.title.compareTo(c.title));
    }
    return buckets;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.value?.id ?? 'local';
    final async = ref.watch(allActiveSchedulesProvider(userId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
      data: (all) {
        final buckets = _groupByDay(all);
        return Column(
          children: [
            if (_selectionMode) _buildSelectionBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= _narrowBreakpoint) {
                    return _buildWideGrid(buckets);
                  }
                  return _buildNarrowTabs(buckets);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionBar() {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: '선택 해제',
                onPressed: _clearSelection,
              ),
              Expanded(
                child: Text(
                  '${_selectedIds.length}개 선택됨',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: _confirmDeleteSelected,
                icon: const Icon(Icons.delete_outline),
                label: const Text('삭제'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideGrid(List<_DayBuckets> buckets) {
    return Column(
      children: [
        _WeekHeader(
          weekStart: _weekStart,
          onPrev: _prevWeek,
          onNext: _nextWeek,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _DayColumn(
                    dayLabel: _dayLabels[i],
                    date: _weekStart.add(Duration(days: i)),
                    bucket: buckets[i],
                    selectedIds: _selectedIds,
                    selectionMode: _selectionMode,
                    onToggleSelection: _toggleSelection,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowTabs(List<_DayBuckets> buckets) {
    final todayIndex =
        (DateTime.now().weekday - DateTime.monday).clamp(0, 6);
    return DefaultTabController(
      length: 7,
      initialIndex: todayIndex,
      child: Column(
        children: [
          _WeekHeader(
            weekStart: _weekStart,
            onPrev: _prevWeek,
            onNext: _nextWeek,
          ),
          TabBar(
            isScrollable: true,
            tabs: [
              for (var i = 0; i < 7; i++)
                Tab(
                  text: '${_dayLabels[i]} '
                      '${_weekStart.add(Duration(days: i)).day}',
                ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (var i = 0; i < 7; i++)
                  _DayColumn(
                    dayLabel: _dayLabels[i],
                    date: _weekStart.add(Duration(days: i)),
                    bucket: buckets[i],
                    selectedIds: _selectedIds,
                    selectionMode: _selectionMode,
                    onToggleSelection: _toggleSelection,
                    showHeader: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final end = weekStart.add(const Duration(days: 6));
    final startMonth = weekStart.month.toString().padLeft(2, '0');
    final startDay = weekStart.day.toString().padLeft(2, '0');
    final endMonth = end.month.toString().padLeft(2, '0');
    final endDay = end.day.toString().padLeft(2, '0');
    final startLabel = '${weekStart.year}.$startMonth.$startDay';
    final endLabel = '$endMonth.$endDay';
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: '이전 주',
          ),
          Expanded(
            child: Center(
              child: Text(
                '$startLabel ~ $endLabel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            tooltip: '다음 주',
          ),
        ],
      ),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  const _DayColumn({
    required this.dayLabel,
    required this.date,
    required this.bucket,
    required this.selectedIds,
    required this.selectionMode,
    required this.onToggleSelection,
    this.showHeader = true,
  });

  final String dayLabel;
  final DateTime date;
  final _DayBuckets bucket;
  final Set<int> selectedIds;
  final bool selectionMode;
  final ValueChanged<int> onToggleSelection;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmpty = bucket.timeSlot.isEmpty && bucket.dayOnly.isEmpty;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                '$dayLabel ${date.day}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          if (isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '일정 없음',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final s in bucket.timeSlot)
                    _ScheduleCard(
                      schedule: s,
                      showTime: true,
                      isSelected: selectedIds.contains(s.id),
                      selectionMode: selectionMode,
                      onToggleSelection: onToggleSelection,
                    ),
                  if (bucket.dayOnly.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 12, 8, 4),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '할일',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    for (final s in bucket.dayOnly)
                      _ScheduleCard(
                        schedule: s,
                        showTime: false,
                        isSelected: selectedIds.contains(s.id),
                        selectionMode: selectionMode,
                        onToggleSelection: onToggleSelection,
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.showTime,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelection,
  });

  final Schedule schedule;
  final bool showTime;
  final bool isSelected;
  final bool selectionMode;
  final ValueChanged<int> onToggleSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = schedule.isCompleted
        ? const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          )
        : null;
    final selectedColor = Theme.of(context).colorScheme.primaryContainer;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: isSelected ? selectedColor : null,
      child: InkWell(
        onTap: selectionMode
            ? () => onToggleSelection(schedule.id)
            : () => context.push('/schedule/edit/${schedule.id}'),
        onLongPress: () {
          if (selectionMode) {
            onToggleSelection(schedule.id);
          } else {
            onToggleSelection(schedule.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                )
              else
                Checkbox(
                value: schedule.isCompleted,
                onChanged: (v) {
                  unawaited(
                    ref
                        .read(scheduleActionsProvider.notifier)
                        .updateSchedule(
                          id: schedule.id,
                          isCompleted: v ?? false,
                        ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTime && schedule.startTime != null)
                      Text(
                        _formatTime(schedule.startTime!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      schedule.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle ??
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      _categoryLabel(schedule.category),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 단일 삭제 확인 다이얼로그는 selection mode 의 일괄 삭제로 대체.
  // 삭제하려면 카드를 길게 눌러 선택 모드 진입 후 상단 [삭제] 버튼 사용.

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  String _categoryLabel(String value) {
    final cat = ScheduleCategory.fromString(value);
    switch (cat) {
      case ScheduleCategory.work:
        return '업무';
      case ScheduleCategory.study:
        return '공부';
      case ScheduleCategory.hobby:
        return '취미';
      case ScheduleCategory.health:
        return '건강';
      case ScheduleCategory.etc:
        return '기타';
    }
  }
}

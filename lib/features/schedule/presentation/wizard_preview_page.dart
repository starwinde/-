import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:routinemon/features/schedule/application/wizard_state.dart';
import 'package:routinemon/features/schedule/data/weekly_wizard_service.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/presentation/weekly_grid_view.dart';

/// Preview of LLM-generated weekly schedule. Users can remove items before
/// bulk-applying them via the schedule repository.
class WizardPreviewPage extends ConsumerStatefulWidget {
  /// Creates the preview page. Reads wizard answers from [wizardStateProvider].
  const WizardPreviewPage({super.key});

  @override
  ConsumerState<WizardPreviewPage> createState() =>
      _WizardPreviewPageState();
}

class _WizardPreviewPageState extends ConsumerState<WizardPreviewPage> {
  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  WeeklyWizardResponse? _response;
  bool _loading = true;
  String? _error;
  bool _applying = false;
  bool _refining = false;
  final Map<String, String> _followupAnswers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    final answers = ref.read(wizardStateProvider.notifier).toAnswers();
    if (answers == null) {
      setState(() {
        _loading = false;
        _error = '답변이 부족합니다. 이전 단계로 돌아가세요.';
      });
      return;
    }
    try {
      final service = ref.read(weeklyWizardServiceProvider);
      final weekStart = WeeklyGridView.mondayOfWeek(DateTime.now());
      final userId = ref.read(authProvider).value?.id;
      final res = await service.generate(
        answers: answers,
        weekStart: weekStart,
        userId: userId,
      );
      if (!mounted) return;
      setState(() {
        _response = res;
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'LLM 호출 실패: $e';
      });
    }
  }

  Future<void> _refine() async {
    final answers = ref.read(wizardStateProvider.notifier).toAnswers();
    final resp = _response;
    if (answers == null || resp == null) return;
    setState(() {
      _refining = true;
      _error = null;
    });
    try {
      final service = ref.read(weeklyWizardServiceProvider);
      final weekStart = WeeklyGridView.mondayOfWeek(DateTime.now());
      final userId = ref.read(authProvider).value?.id;
      final refined = await service.refine(
        answers: answers,
        weekStart: weekStart,
        previousItems: resp.items,
        followupAnswers: Map<String, String>.from(_followupAnswers),
        userId: userId,
      );
      if (!mounted) return;
      setState(() {
        _response = refined;
        _followupAnswers.clear();
        _refining = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('재생성 완료: ${refined.items.length}개 일정')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _refining = false;
        _error = '재생성 실패: $e';
      });
    }
  }

  void _removeAt(int index) {
    final res = _response;
    if (res == null) return;
    final newList = List<GeneratedScheduleItem>.from(res.items)
      ..removeAt(index);
    setState(() {
      _response = res.copyWith(items: newList);
    });
  }

  Future<void> _apply() async {
    final res = _response;
    if (res == null || res.items.isEmpty || _applying) return;
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }
    setState(() => _applying = true);
    final weekStart = WeeklyGridView.mondayOfWeek(DateTime.now());
    final repo = ref.read(scheduleRepositoryProvider);
    final companions = [
      for (final item in res.items)
        SchedulesCompanion.insert(
          userId: userId,
          title: item.title,
          category: item.category.name,
          tags: Value(jsonEncode(item.tags)),
          startTime: Value(item.resolveStart(weekStart)),
          endTime: Value(item.resolveEnd(weekStart)),
        ),
    ];
    try {
      await repo.insertMany(companions);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${companions.length}개 일정 적용됨')),
      );
      context.go('/schedule');
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _applying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('적용 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _response?.items ?? const <GeneratedScheduleItem>[];
    return Scaffold(
      appBar: AppBar(title: const Text('주간 일정 미리보기')),
      body: _buildBody(items),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (_applying || _refining)
                      ? null
                      : () => context.pop(),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: (items.isEmpty || _applying || _refining)
                      ? null
                      : _apply,
                  child: _applying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('적용 (${items.length})'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<GeneratedScheduleItem> items) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(_error!)),
      );
    }
    if (items.isEmpty && (_response?.followupQuestions.isEmpty ?? true)) {
      return const Center(child: Text('생성된 일정 없음'));
    }
    final followupQuestions =
        _response?.followupQuestions ?? const <FollowupQuestion>[];
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, index) {
              final it = items[index];
              final dayLabel = _dayLabels[it.dayOfWeek.clamp(0, 6)];
              return Dismissible(
                key: ValueKey(
                  '${it.title}-${it.dayOfWeek}-${it.startTime}-$index',
                ),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _removeAt(index),
                child: ListTile(
                  title: Text(it.title),
                  subtitle: Text(
                    '$dayLabel ${it.startTime}-${it.endTime} '
                    '(${it.category.name})',
                  ),
                ),
              );
            },
            childCount: items.length,
          ),
        ),
        if (followupQuestions.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildFollowupSection(followupQuestions),
          ),
      ],
    );
  }

  Widget _buildFollowupSection(List<FollowupQuestion> qs) {
    final allAnswered =
        qs.every((q) => _followupAnswers.containsKey(q.id));
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.auto_awesome),
      title: const Text(
        '🎯 더 구체화하기',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'AI가 판단한 보조 질문 ${qs.length}개. 답변 후 재생성하면 일정이 더 정교해집니다.',
      ),
      children: [
        for (final q in qs) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              q.question,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          RadioGroup<String>(
            groupValue: _followupAnswers[q.id],
            onChanged: (v) {
              if (_refining || v == null) return;
              setState(() => _followupAnswers[q.id] = v);
            },
            child: Column(
              children: [
                for (final opt in q.options)
                  RadioListTile<String>(
                    dense: true,
                    value: opt.value,
                    title: Text(opt.label),
                  ),
              ],
            ),
          ),
          const Divider(),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: (_refining || !allAnswered) ? null : _refine,
            icon: _refining
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_refining ? '재생성 중…' : '재생성'),
          ),
        ),
      ],
    );
  }
}

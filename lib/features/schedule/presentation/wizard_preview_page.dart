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
import 'package:routinemon/features/schedule/domain/awake_window.dart';
import 'package:routinemon/features/schedule/domain/schedule_conflict_detector.dart';
import 'package:routinemon/features/schedule/presentation/weekly_grid_view.dart';

/// Preview of generated weekly schedule. Path A 기본 즉시 표시 + 행별 충돌 뱃지.
class WizardPreviewPage extends ConsumerStatefulWidget {
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
  bool _enhancing = false;
  EnhanceObjective? _selectedObjective;
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
      final existing = await _fetchExistingThisWeek(userId, weekStart);
      final res = await service.generate(
        answers: answers,
        weekStart: weekStart,
        userId: userId,
        existingThisWeek: existing,
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
        _error = '생성 실패: $e';
      });
    }
  }

  Future<void> _refine() async {
    final answers = ref.read(wizardStateProvider.notifier).toAnswers();
    final resp = _response;
    if (answers == null || resp == null) return;

    final notifier = ref.read(refinementSessionProvider.notifier);
    var session = ref.read(refinementSessionProvider);
    if (session == null) {
      final convId = resp.conversationId ??
          DateTime.now().millisecondsSinceEpoch.toString();
      notifier.start(convId);
      session = ref.read(refinementSessionProvider);
    }
    if (session == null || session.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재생성 5회 한도에 도달했습니다')),
      );
      return;
    }

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
        session: session,
        followupAnswers: Map<String, String>.from(_followupAnswers),
        userId: userId,
      );
      notifier.tryAppend(
        RefinementTurn(
          turn: session.turnCount + 1,
          items: refined.items,
          followupAnswers: Map.unmodifiable(_followupAnswers),
          diffSummary: refined.diffSummary,
          timestamp: DateTime.now(),
        ),
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

  EnhanceObjective _autoRecommendObjective(
    List<GeneratedScheduleItem> items,
  ) {
    if (items.isEmpty) return EnhanceObjective.refineCategories;
    final workCount =
        items.where((i) => i.category.name == 'work').length;
    if (workCount / items.length >= 0.6) {
      return EnhanceObjective.rebalanceLoad;
    }
    final titleCounts = <String, int>{};
    for (final i in items) {
      titleCounts[i.title] = (titleCounts[i.title] ?? 0) + 1;
    }
    if (titleCounts.values.any((c) => c >= 3)) {
      return EnhanceObjective.diversifyTitles;
    }
    final hasRecovery =
        items.any((i) => i.category.name == 'health' || i.tags.contains('rest'));
    if (items.length >= 14 && !hasRecovery) {
      return EnhanceObjective.addRecovery;
    }
    return EnhanceObjective.refineCategories;
  }

  static const _objectiveLabels = {
    EnhanceObjective.diversifyTitles: '제목 다양화',
    EnhanceObjective.rebalanceLoad: '부하 균형',
    EnhanceObjective.addRecovery: '회복 추가',
    EnhanceObjective.refineCategories: '카테고리 정제',
  };

  Future<void> _enhance() async {
    final res = _response;
    final answers = ref.read(wizardStateProvider.notifier).toAnswers();
    if (res == null || answers == null || _enhancing) return;
    final objective =
        _selectedObjective ?? _autoRecommendObjective(res.items);
    setState(() {
      _enhancing = true;
      _error = null;
    });
    try {
      final service = ref.read(weeklyWizardServiceProvider);
      final weekStart = WeeklyGridView.mondayOfWeek(DateTime.now());
      final userId = ref.read(authProvider).value?.id;
      final enhanced = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: res.items,
        objective: objective,
        userId: userId,
      );
      if (!mounted) return;
      final fellBack = enhanced.source == WizardSource.rule;
      setState(() {
        _response = enhanced;
        _enhancing = false;
        _selectedObjective = objective;
      });
      if (fellBack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI 향상 실패 — 기본 결과 유지'),
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _enhancing = false;
        _error = 'AI 향상 실패: $e';
      });
    }
  }

  Future<List<ExistingScheduleRef>> _fetchExistingThisWeek(
    String? userId,
    DateTime weekStart,
  ) async {
    if (userId == null) return const [];
    final repo = ref.read(scheduleRepositoryProvider);
    final all = await repo.watchAllActive(userId).first;
    final weekEnd = weekStart.add(const Duration(days: 7));
    return [
      for (final s in all)
        if (s.startTime != null &&
            s.endTime != null &&
            s.startTime!.isBefore(weekEnd) &&
            s.endTime!.isAfter(weekStart))
          (id: s.id, start: s.startTime, end: s.endTime),
    ];
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

    final weekStartForRedetect = WeeklyGridView.mondayOfWeek(DateTime.now());
    final answersForRedetect =
        ref.read(wizardStateProvider.notifier).toAnswers();
    var freshConflicts = res.conflicts;
    if (answersForRedetect != null) {
      final existing =
          await _fetchExistingThisWeek(userId, weekStartForRedetect);
      final awake = AwakeWindow.resolve(
        answersForRedetect.wakeTime,
        answersForRedetect.sleepTime,
        answersForRedetect.chronotype,
      );
      freshConflicts = const ScheduleConflictDetector().detect(
        proposed: res.items,
        existingThisWeek: existing,
        awake: awake,
        weekStart: weekStartForRedetect,
      );
      if (mounted && freshConflicts.length != res.conflicts.length) {
        setState(() {
          _response = res.copyWith(conflicts: freshConflicts);
        });
      }
    }
    final hasError = freshConflicts
        .any((c) => c.severity == ConflictSeverity.error);
    if (hasError) {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('충돌이 감지되었습니다'),
          content: Text(
            '에러 ${freshConflicts.where((c) => c.severity == ConflictSeverity.error).length}건이 있습니다. 그래도 적용하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('그래도 적용'),
            ),
          ],
        ),
      );
      if (ok != true) return;
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

  void _showConflictDetails(int index) {
    final res = _response;
    if (res == null) return;
    final related =
        res.conflicts.where((c) => c.indices.contains(index)).toList();
    if (related.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '충돌 ${related.length}건',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final c in related) ...[
                Row(
                  children: [
                    Icon(
                      c.severity == ConflictSeverity.error
                          ? Icons.error
                          : Icons.warning,
                      color: c.severity == ConflictSeverity.error
                          ? Colors.red
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c.message)),
                  ],
                ),
                if (c.indices.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: Text(
                      '관련 행: ${c.indices.map((i) => i + 1).join(", ")}',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                const Divider(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  ConflictSeverity? _severityAt(int index) {
    final res = _response;
    if (res == null) return null;
    final related = res.conflicts.where((c) => c.indices.contains(index));
    if (related.isEmpty) return null;
    if (related.any((c) => c.severity == ConflictSeverity.error)) {
      return ConflictSeverity.error;
    }
    return ConflictSeverity.warning;
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

  Widget _buildEnhanceCard(List<GeneratedScheduleItem> items) {
    final hasLlmSource = items.any((i) => i.source == WizardSource.llm);
    final autoObj = _autoRecommendObjective(items);
    final selected = _selectedObjective ?? autoObj;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AI 향상 (실험)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                if (hasLlmSource)
                  const Chip(label: Text('AI 적용됨')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '추천: ${_objectiveLabels[autoObj]}. 다른 목적으로 변경할 수 있어요.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: EnhanceObjective.values.map((o) {
                return FilterChip(
                  label: Text(_objectiveLabels[o]!),
                  selected: o == selected,
                  onSelected: _enhancing
                      ? null
                      : (v) => setState(() => _selectedObjective = o),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: _enhancing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_enhancing ? '생성 중…' : 'AI 향상 실행'),
              onPressed:
                  _enhancing || items.isEmpty ? null : _enhance,
            ),
          ],
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
    final conflicts = _response?.conflicts ?? const <ConflictReport>[];
    final errCount =
        conflicts.where((c) => c.severity == ConflictSeverity.error).length;
    final warnCount = conflicts.length - errCount;
    final session = ref.watch(refinementSessionProvider);
    final lastDiffSummary = _response?.diffSummary;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildEnhanceCard(items),
        ),
        if (conflicts.isNotEmpty)
          SliverToBoxAdapter(
            child: WizardConflictsBanner(
              errCount: errCount,
              warnCount: warnCount,
            ),
          ),
        if (session != null && session.turnCount > 0)
          SliverToBoxAdapter(
            child: WizardRefinementCounter(
              turnCount: session.turnCount,
              maxTurns: RefinementSession.maxTurns,
            ),
          ),
        if (lastDiffSummary != null && lastDiffSummary.trim().isNotEmpty)
          SliverToBoxAdapter(
            child: WizardDiffSummaryCard(summary: lastDiffSummary),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, index) {
              final it = items[index];
              final dayLabel = _dayLabels[it.dayOfWeek.clamp(0, 6)];
              final severity = _severityAt(index);
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
                  leading: severity != null
                      ? IconButton(
                          icon: Icon(
                            severity == ConflictSeverity.error
                                ? Icons.error
                                : Icons.warning,
                            color: severity == ConflictSeverity.error
                                ? Colors.red
                                : Colors.orange,
                          ),
                          tooltip: '충돌 상세',
                          onPressed: () => _showConflictDetails(index),
                        )
                      : null,
                  title: Text(it.title),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$dayLabel ${it.startTime}-${it.endTime} '
                          '(${it.category.name})',
                        ),
                      ),
                      WizardSourceChip(source: it.source),
                    ],
                  ),
                  onTap: severity != null
                      ? () => _showConflictDetails(index)
                      : null,
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

@visibleForTesting
class WizardConflictsBanner extends StatelessWidget {
  const WizardConflictsBanner({
    super.key,
    required this.errCount,
    required this.warnCount,
  });

  final int errCount;
  final int warnCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: errCount > 0 ? Colors.red.shade50 : Colors.orange.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            errCount > 0 ? Icons.error : Icons.warning,
            color: errCount > 0 ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '충돌 ${errCount + warnCount}건 — error $errCount건 / warning $warnCount건',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
class WizardRefinementCounter extends StatelessWidget {
  const WizardRefinementCounter({
    super.key,
    required this.turnCount,
    required this.maxTurns,
  });

  final int turnCount;
  final int maxTurns;

  @override
  Widget build(BuildContext context) {
    final isFull = turnCount >= maxTurns;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Icon(
            isFull ? Icons.lock : Icons.refresh,
            size: 16,
            color: isFull ? Colors.grey : Colors.blue,
          ),
          const SizedBox(width: 6),
          Text('재생성 $turnCount/$maxTurns'),
          const Spacer(),
          if (isFull)
            const Text(
              '한도 도달',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

@visibleForTesting
class WizardDiffSummaryCard extends StatelessWidget {
  const WizardDiffSummaryCard({super.key, required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.purple),
            const SizedBox(width: 8),
            Expanded(child: Text(summary)),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
class WizardSourceChip extends StatelessWidget {
  const WizardSourceChip({super.key, required this.source});

  final WizardSource source;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (source) {
      WizardSource.rule => ('기본', Colors.grey.shade300),
      WizardSource.llm => ('AI 향상', Colors.purple.shade100),
      WizardSource.preset => ('기본 (폴백)', Colors.grey.shade400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

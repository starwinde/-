import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/report_aggregator.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/awake_window.dart';
import 'package:routinemon/features/schedule/domain/rule_based_planner.dart';
import 'package:routinemon/features/schedule/domain/schedule_conflict_detector.dart';

part 'weekly_wizard_service.g.dart';

/// Weekly schedule generation service.
///
/// `generate()` 는 **Path A (rule-based)** 를 기본 경로로 사용한다 (ADR 0001).
/// LLM 호출 0건. 동기적으로 결정론 알고리즘 + conflict detect 수행.
///
/// `enhance()` 는 LLM 향상 경로 (모든 사용자 노출, 3-retry backoff, rules.md §9.3).
/// `refine()` 은 LLM multi-turn 재생성 (Issue 07 에서 multi-turn 으로 확장).
class WeeklyWizardService {
  WeeklyWizardService(
    this._client,
    this._aggregator, {
    RuleBasedPlanner planner = const RuleBasedPlanner(),
    ScheduleConflictDetector conflictDetector =
        const ScheduleConflictDetector(),
    Random? random,
    Future<void> Function(Duration)? sleep,
  })  : _planner = planner,
        _conflictDetector = conflictDetector,
        _random = random ?? Random(),
        _sleep = sleep ?? Future.delayed;

  static const _path = '/webhook/routinemon/weekly-wizard';

  /// rules.md §9.3: 3회 재시도 후 폴백.
  static const _retryDelays = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
    Duration(milliseconds: 3500),
  ];

  final ApiClient _client;
  final ReportAggregator _aggregator;
  final RuleBasedPlanner _planner;
  final ScheduleConflictDetector _conflictDetector;
  final Random _random;
  final Future<void> Function(Duration) _sleep;

  /// Path A — rule-based, deterministic, no LLM call.
  Future<WeeklyWizardResponse> generate({
    required WizardAnswers answers,
    required DateTime weekStart,
    String? userId,
    Iterable<ExistingScheduleRef> existingThisWeek = const [],
  }) async {
    final enriched = await _withPastContext(answers, userId);
    final planResult =
        _planner.plan(answers: enriched, weekStart: weekStart);
    final awake = AwakeWindow.resolve(
      enriched.wakeTime,
      enriched.sleepTime,
      enriched.chronotype,
    );
    final conflicts = _conflictDetector.detect(
      proposed: planResult.items,
      existingThisWeek: existingThisWeek,
      awake: awake,
      weekStart: weekStart,
    );
    return WeeklyWizardResponse(
      items: planResult.items,
      source: WizardSource.rule,
      conflicts: conflicts,
      warnings: planResult.warnings,
    );
  }

  /// Path B — LLM enhance (모든 사용자 노출). 3-retry backoff, 실패 시 seed 폴백.
  Future<WeeklyWizardResponse> enhance({
    required WizardAnswers answers,
    required DateTime weekStart,
    required List<GeneratedScheduleItem> seed,
    required EnhanceObjective objective,
    String? conversationId,
    int turn = 1,
    String? userId,
  }) async {
    final enriched = await _withPastContext(answers, userId);
    final convId = conversationId ?? _newConversationId();
    final body = <String, dynamic>{
      'mode': 'enhance',
      'answers': enriched.toJson(),
      'week_start': _ymd(weekStart),
      'rule_based_seed':
          seed.map((i) => i.toJson()).toList(growable: false),
      'enhance_objective': _objectiveToJson(objective),
      'conversation_id': convId,
      'turn': turn,
    };
    return _postWithRetry(
      body,
      fallback: () => WeeklyWizardResponse(
        items: seed,
        source: WizardSource.rule,
        conversationId: convId,
        turn: turn,
        warnings: const ['enhance 실패: rule-based seed 로 폴백'],
      ),
    );
  }

  /// Multi-turn refinement (Issue 07). 마지막 2턴 history 윈도잉, 5턴 상한.
  ///
  /// [session] 은 비어있을 수 있다 (첫 호출 시 turnCount=0 → server 가 first-pass 처리).
  /// 항상 `mode=refine` 으로 호출.
  Future<WeeklyWizardResponse> refine({
    required WizardAnswers answers,
    required DateTime weekStart,
    required RefinementSession session,
    required Map<String, String> followupAnswers,
    String? userId,
  }) async {
    final enriched = await _withPastContext(answers, userId);
    final turn = session.turnCount + 1;
    return _post({
      'mode': 'refine',
      'answers': enriched.toJson(),
      'week_start': _ymd(weekStart),
      'conversation_id': session.conversationId,
      'turn': turn,
      'previous_turns':
          session.window.map((t) => t.toJson()).toList(growable: false),
      'followup_answers': followupAnswers,
    });
  }

  Future<WizardAnswers> _withPastContext(
    WizardAnswers answers,
    String? userId,
  ) async {
    if (userId == null || userId.isEmpty) return answers;
    if (answers.pastWeekContext != null) return answers;
    try {
      final ctx = await _aggregator.pastWeekContext(userId: userId);
      if (ctx == null) return answers;
      return answers.copyWith(pastWeekContext: ctx);
    } on Exception {
      return answers;
    }
  }

  Future<WeeklyWizardResponse> _post(Map<String, dynamic> body) async {
    try {
      final response = await _client.post(_path, body: body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _preset();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeeklyWizardResponse.fromJson(json);
    } on Exception {
      return _preset();
    }
  }

  Future<WeeklyWizardResponse> _postWithRetry(
    Map<String, dynamic> body, {
    required WeeklyWizardResponse Function() fallback,
  }) async {
    for (var attempt = 0; attempt < _retryDelays.length; attempt++) {
      try {
        final response = await _client.post(_path, body: body);
        final code = response.statusCode;
        if (code >= 400 && code < 500) {
          // 4xx 즉시 폴백 (요청 잘못)
          return fallback();
        }
        if (code < 200 || code >= 300) {
          await _backoff(_retryDelays[attempt]);
          continue;
        }
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final parsed = WeeklyWizardResponse.fromJson(json);
          if (parsed.items.isEmpty) {
            await _backoff(_retryDelays[attempt]);
            continue;
          }
          return parsed;
        } on FormatException {
          await _backoff(_retryDelays[attempt]);
          continue;
        }
      } on TimeoutException {
        await _backoff(_retryDelays[attempt]);
        continue;
      } on Exception {
        await _backoff(_retryDelays[attempt]);
        continue;
      }
    }
    return fallback();
  }

  Future<void> _backoff(Duration base) async {
    final jitterRange = (base.inMilliseconds * 0.2).round();
    final jitter = _random.nextInt(2 * jitterRange + 1) - jitterRange;
    await _sleep(Duration(milliseconds: base.inMilliseconds + jitter));
  }

  String _newConversationId() {
    final rnd = _random.nextInt(1 << 32);
    return DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
        rnd.toRadixString(16);
  }

  String _objectiveToJson(EnhanceObjective o) {
    switch (o) {
      case EnhanceObjective.diversifyTitles:
        return 'diversify_titles';
      case EnhanceObjective.rebalanceLoad:
        return 'rebalance_load';
      case EnhanceObjective.addRecovery:
        return 'add_recovery';
      case EnhanceObjective.refineCategories:
        return 'refine_categories';
    }
  }

  String _ymd(DateTime d) => d.toIso8601String().substring(0, 10);

  WeeklyWizardResponse _preset() =>
      const WeeklyWizardResponse(items: [], source: WizardSource.preset);
}

/// Provides [WeeklyWizardService] wired to the global [ApiClient] and
/// [ReportAggregator].
@riverpod
WeeklyWizardService weeklyWizardService(Ref ref) => WeeklyWizardService(
      ref.watch(apiClientProvider),
      ref.watch(reportAggregatorProvider),
    );

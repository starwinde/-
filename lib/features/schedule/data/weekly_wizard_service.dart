import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/report_aggregator.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

part 'weekly_wizard_service.g.dart';

/// Calls n8n `routinemon-weekly-schedule-wizard` webhook to generate a weekly
/// schedule from user lifestyle answers + the user's past-N-week execution
/// context (작성/이행/체크 패턴). Returns preset fallback on any error.
class WeeklyWizardService {
  /// Creates a service backed by [client] and [aggregator].
  WeeklyWizardService(this._client, this._aggregator);

  static const _path = '/webhook/routinemon/weekly-wizard';

  final ApiClient _client;
  final ReportAggregator _aggregator;

  /// Generates a weekly schedule plan.
  ///
  /// [weekStart] must be a Monday (week start in the app).
  /// [userId] is used to look up past execution context (last 4 weeks).
  Future<WeeklyWizardResponse> generate({
    required WizardAnswers answers,
    required DateTime weekStart,
    String? userId,
  }) async {
    final enriched = await _withPastContext(answers, userId);
    return _post({
      'answers': enriched.toJson(),
      'week_start': _ymd(weekStart),
    });
  }

  /// Second-pass refinement: send original answers + previous items +
  /// follow-up answers back to the n8n workflow.
  Future<WeeklyWizardResponse> refine({
    required WizardAnswers answers,
    required DateTime weekStart,
    required List<GeneratedScheduleItem> previousItems,
    required Map<String, String> followupAnswers,
    String? userId,
  }) async {
    final enriched = await _withPastContext(answers, userId);
    return _post({
      'answers': enriched.toJson(),
      'week_start': _ymd(weekStart),
      'refinement': {
        'previous_items':
            previousItems.map((i) => i.toJson()).toList(growable: false),
        'followup_answers': followupAnswers,
      },
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

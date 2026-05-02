import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

part 'ai_report_service.g.dart';

/// Generates weekly/monthly wellness reports via the local LLM
/// (llama-server-8600-v2) routed through n8n webhooks. On any failure
/// returns a numeric preset summary so the UI still has something to show.
class AiReportService {
  /// Creates a service backed by [client].
  AiReportService(this._client);

  static const _weeklyPath = '/webhook/routinemon/ai/weekly-report';
  static const _monthlyPath = '/webhook/routinemon/ai/monthly-report';

  final ApiClient _client;

  /// Generates a report for [req]. Returns preset fallback on any failure.
  Future<AiReportResponse> generate(AiReportRequest req) async {
    final path = req.period == ReportPeriod.weekly
        ? _weeklyPath
        : _monthlyPath;
    try {
      final response = await _client.post(path, body: req.toJson());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _preset(req);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AiReportResponse.fromJson(json);
    } on Exception {
      return _preset(req);
    }
  }

  AiReportResponse _preset(AiReportRequest req) {
    final d = req.data;
    final ratioPct = (d.avgFocusRatio * 100).round();
    final taskPct = d.tasksTotal == 0
        ? 0
        : ((d.tasksCompleted / d.tasksTotal) * 100).round();
    final summary =
        '집중 세션 ${d.focusSessions}회, 평균 집중도 $ratioPct%, '
        '할일 $taskPct% 완료 (연속 ${d.streakDays}일).';
    return AiReportResponse(
      summary: summary,
      insights: const [],
      suggestions: const [],
      encouragement: '이번 주기의 수치를 확인해 보세요.',
      source: AiReportSource.preset,
    );
  }
}

/// Provides [AiReportService] wired to the global [ApiClient].
@riverpod
AiReportService aiReportService(Ref ref) =>
    AiReportService(ref.watch(apiClientProvider));

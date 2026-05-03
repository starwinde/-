import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

/// Integration test for AI weekly/monthly report n8n workflows.
///
/// Requirements:
/// - n8n running at https://localhost:5678 with active
///   `routinemon-ai-weekly-report` + `routinemon-ai-monthly-report` workflows
/// - llama-server-8600-v2 reachable from n8n
///
/// Run: `flutter test test/integration/ai_report_integration_test.dart`
void main() {
  const weeklyUrl = 'https://localhost:5678/webhook/routinemon/ai/weekly-report';
  const monthlyUrl =
      'https://localhost:5678/webhook/routinemon/ai/monthly-report';

  late HttpClient client;

  setUpAll(() {
    client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => host == 'localhost';
  });

  tearDownAll(() {
    client.close(force: true);
  });

  Future<AiReportResponse> post(String url, Map<String, dynamic> body) async {
    final uri = Uri.parse(url);
    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    expect(response.statusCode, 200,
        reason: 'Non-200 from $url: $responseBody');
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return AiReportResponse.fromJson(json);
  }

  final sampleData = <String, dynamic>{
    'user_id': 'integration-test-user',
    'period_start': '2026-04-11',
    'period_end': '2026-04-18',
    'data': <String, dynamic>{
      'focus_sessions': 10,
      'avg_focus_ratio': 0.75,
      'tasks_completed': 15,
      'tasks_total': 20,
      'streak_days': 5,
    },
    'user_locale': 'ko',
  };

  test('weekly: returns llm source with non-empty summary', () async {
    final res = await post(weeklyUrl, {...sampleData, 'period': 'weekly'});
    expect(res.source, AiReportSource.llm,
        reason: 'Expected LLM inference');
    expect(res.summary, isNotEmpty);
  }, timeout: const Timeout(Duration(seconds: 180)));

  test('monthly: returns llm source', () async {
    final monthlyData = {
      ...sampleData,
      'period': 'monthly',
      'period_start': '2026-03-18',
      'data': {
        'focus_sessions': 40,
        'avg_focus_ratio': 0.70,
        'tasks_completed': 60,
        'tasks_total': 80,
        'streak_days': 20,
      },
    };
    final res = await post(monthlyUrl, monthlyData);
    expect(res.source, AiReportSource.llm);
    expect(res.summary, isNotEmpty);
  }, timeout: const Timeout(Duration(seconds: 180)));

  test('weekly: missing required field falls back to preset', () async {
    // Omit the required `data` field → n8n Validate Input 실패 → Preset Fallback
    final res = await post(weeklyUrl, {
      'user_id': 'x',
      'period': 'weekly',
      'period_start': '2026-04-11',
      'period_end': '2026-04-18',
      'user_locale': 'ko',
      // data omitted
    });
    expect(res.source, AiReportSource.preset);
  }, timeout: const Timeout(Duration(seconds: 10)));
}

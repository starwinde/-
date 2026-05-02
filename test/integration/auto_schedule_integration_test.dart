import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

/// Integration test against real n8n + llama-server-8600-v2.
///
/// Requirements:
/// - n8n running at https://localhost:5678 with active `routinemon-auto-schedule` workflow
/// - llama-server-8600-v2 reachable at http://localhost:8600 from n8n
///
/// Run: `flutter test test/integration/auto_schedule_integration_test.dart`
///
/// Uses dart:io HttpClient with badCertificateCallback to accept the
/// self-signed localhost cert.
void main() {
  const webhookUrl = 'https://localhost:5678/webhook/routinemon/auto-schedule';

  late HttpClient client;

  setUpAll(() {
    client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => host == 'localhost';
  });

  tearDownAll(() {
    client.close(force: true);
  });

  Future<AutoScheduleResponse> post(Map<String, dynamic> body) async {
    final uri = Uri.parse(webhookUrl);
    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    expect(response.statusCode, 200,
        reason: 'Non-200 from webhook: $responseBody');
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return AutoScheduleResponse.fromJson(json);
  }

  test('LLM path: valid Korean schedule text returns llm source', () async {
    final res = await post({
      'text': '내일 오후 2시 팀 미팅',
      'user_locale': 'ko',
    });
    expect(res.source, AutoScheduleSource.llm,
        reason: 'Expected LLM inference, got ${res.source}');
    expect(res.title, isNotEmpty);
    expect(res.confidence, greaterThanOrEqualTo(0.0));
    expect(res.confidence, lessThanOrEqualTo(1.0));
    // category is one of the 5 enum values; fromString falls back to etc.
    expect(ScheduleCategory.values, contains(res.category));
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('Preset path: empty text returns preset source', () async {
    final res = await post({'text': '', 'user_locale': 'ko'});
    expect(res.source, AutoScheduleSource.preset);
    expect(res.title, isEmpty);
    expect(res.confidence, 0.0);
  }, timeout: const Timeout(Duration(seconds: 10)));

  test('Preset path: blocked content returns preset source', () async {
    final res = await post({
      'text': '자살 생각이 들어',
      'user_locale': 'ko',
    });
    expect(res.source, AutoScheduleSource.preset);
  }, timeout: const Timeout(Duration(seconds: 10)));
}

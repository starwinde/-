import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

/// Integration test for `routinemon-weekly-schedule-wizard` n8n workflow.
///
/// Requires:
/// - n8n at https://localhost:5678 with active weekly-wizard workflow
/// - llama-server-8600-v2 reachable from n8n
///
/// Run: `flutter test test/integration/weekly_wizard_integration_test.dart`
void main() {
  const url = 'https://localhost:5678/webhook/routinemon/weekly-wizard';

  late HttpClient client;

  setUpAll(() {
    client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => host == 'localhost';
  });

  tearDownAll(() {
    client.close(force: true);
  });

  Future<WeeklyWizardResponse> post(Map<String, dynamic> body) async {
    final req = await client.postUrl(Uri.parse(url));
    req.headers.set('content-type', 'application/json');
    req.headers.set('accept', '*/*');
    req.headers.removeAll('accept-encoding');
    final payload = utf8.encode(jsonEncode(body));
    req.headers.contentLength = payload.length;
    req.add(payload);
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    expect(res.statusCode, 200, reason: 'Non-200: $text');
    final json = jsonDecode(text) as Map<String, dynamic>;
    return WeeklyWizardResponse.fromJson(json);
  }

  final validAnswers = <String, dynamic>{
    'status': 'worker',
    'work_days': 'd5',
    'focus_time': 'morning',
    'exercise': 'light',
    'hobby': 'weekdayEvening',
    'free_time': 'twoHours',
    'fixed_schedules': '',
    'user_locale': 'ko',
  };

  test('LLM path: valid answers → source=llm + items≥5', () async {
    final res = await post({
      'answers': validAnswers,
      'week_start': '2026-04-20',
    });
    expect(res.source, WizardSource.llm);
    expect(res.items.length, greaterThanOrEqualTo(5));
    for (final item in res.items) {
      expect(item.dayOfWeek, inInclusiveRange(0, 6));
      expect(item.title, isNotEmpty);
    }
  }, timeout: const Timeout(Duration(seconds: 180)));

  test('Preset path: blocked keyword in fixed_schedules → source=preset',
      () async {
    final blockedAnswers = Map<String, dynamic>.from(validAnswers)
      ..['fixed_schedules'] = '자살 생각이 들어';
    final res = await post({
      'answers': blockedAnswers,
      'week_start': '2026-04-20',
    });
    expect(res.source, WizardSource.preset);
    expect(res.items, isNotEmpty);
  }, timeout: const Timeout(Duration(seconds: 10)));

  test('Preset path: missing answers object → source=preset', () async {
    final res = await post({
      'week_start': '2026-04-20',
    });
    expect(res.source, WizardSource.preset);
  }, timeout: const Timeout(Duration(seconds: 10)));
}

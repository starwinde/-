import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/ai/data/ai_report_service.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  late _MockApiClient client;
  late AiReportService service;

  final baseReq = AiReportRequest(
    userId: 'u1',
    period: ReportPeriod.weekly,
    periodStart: DateTime.utc(2026, 4, 11),
    periodEnd: DateTime.utc(2026, 4, 18),
    data: const AiReportInputData(
      focusSessions: 10,
      avgFocusRatio: 0.75,
      tasksCompleted: 15,
      tasksTotal: 20,
      streakDays: 5,
    ),
    userLocale: 'ko',
  );

  setUp(() {
    client = _MockApiClient();
    service = AiReportService(client);
  });

  test('weekly posts to /ai/weekly-report and parses llm response', () async {
    final body = jsonEncode({
      'summary': 's',
      'insights': ['i1'],
      'suggestions': ['sg1'],
      'encouragement': 'e',
      'source': 'llm',
    });
    when(
      () => client.post(any(), body: any(named: 'body')),
    ).thenAnswer(
      (_) async => http.Response(
        body,
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    final res = await service.generate(baseReq);

    expect(res.source, AiReportSource.llm);
    verify(
      () => client.post(
        '/webhook/routinemon/ai/weekly-report',
        body: any(named: 'body'),
      ),
    ).called(1);
  });

  test('monthly posts to /ai/monthly-report path', () async {
    final monthlyReq = baseReq.copyWith(period: ReportPeriod.monthly);
    final body = jsonEncode({
      'summary': 's',
      'insights': <String>[],
      'suggestions': <String>[],
      'encouragement': '',
      'source': 'preset',
    });
    when(
      () => client.post(any(), body: any(named: 'body')),
    ).thenAnswer(
      (_) async => http.Response(
        body,
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    await service.generate(monthlyReq);

    verify(
      () => client.post(
        '/webhook/routinemon/ai/monthly-report',
        body: any(named: 'body'),
      ),
    ).called(1);
  });

  test('non-2xx returns preset fallback', () async {
    when(
      () => client.post(any(), body: any(named: 'body')),
    ).thenAnswer((_) async => http.Response('err', 500));
    final res = await service.generate(baseReq);
    expect(res.source, AiReportSource.preset);
    expect(res.summary, isNotEmpty);
  });

  test('exception returns preset fallback', () async {
    when(
      () => client.post(any(), body: any(named: 'body')),
    ).thenThrow(Exception('x'));
    final res = await service.generate(baseReq);
    expect(res.source, AiReportSource.preset);
  });
}

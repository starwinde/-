import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_service.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('AutoScheduleService.infer', () {
    late _MockApiClient client;
    late AutoScheduleService service;

    setUp(() {
      client = _MockApiClient();
      service = AutoScheduleService(client);
    });

    test('posts to /webhook/routinemon/auto-schedule and parses LLM response',
        () async {
      final bodyJson = jsonEncode({
        'title': '팀 미팅',
        'start_time': '2026-04-19T14:00:00+09:00',
        'end_time': '2026-04-19T15:00:00+09:00',
        'category': 'work',
        'tags': ['meeting'],
        'confidence': 0.9,
        'source': 'llm',
      });
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          bodyJson,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final result = await service.infer(
        text: '내일 오후 2시 팀 미팅',
        userLocale: 'ko',
      );

      expect(result.title, '팀 미팅');
      expect(result.category, ScheduleCategory.work);
      expect(result.source, AutoScheduleSource.llm);
      verify(() => client.post(
            '/webhook/routinemon/auto-schedule',
            body: {
              'text': '내일 오후 2시 팀 미팅',
              'user_locale': 'ko',
            },
          )).called(1);
    });

    test('returns preset fallback on non-2xx status', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final result = await service.infer(text: 'x', userLocale: 'ko');

      expect(result.source, AutoScheduleSource.preset);
      expect(result.category, ScheduleCategory.etc);
      expect(result.confidence, 0.0);
    });

    test('returns preset fallback on JSON parse failure', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('not json', 200));

      final result = await service.infer(text: 'x', userLocale: 'ko');

      expect(result.source, AutoScheduleSource.preset);
    });

    test('returns preset fallback on network exception', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(Exception('network down'));

      final result = await service.infer(text: 'x', userLocale: 'ko');

      expect(result.source, AutoScheduleSource.preset);
    });
  });
}

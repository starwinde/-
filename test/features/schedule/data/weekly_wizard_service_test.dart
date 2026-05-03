import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/report_aggregator.dart';
import 'package:routinemon/features/schedule/data/weekly_wizard_service.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/conflict_report.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockAggregator extends Mock implements ReportAggregator {}

WizardAnswers _sampleAnswers({
  PastWeekContext? pastWeekContext,
  String? fixedSchedules,
}) =>
    WizardAnswers(
      status: LifestyleStatus.worker,
      workDays: WorkDays.d5,
      focusTime: FocusTimeWindow.morning,
      exercise: ExerciseFrequency.light,
      hobby: HobbyPreference.weekend,
      freeTime: FreeTimeMin.twoHours,
      userLocale: 'ko',
      wakeTime: WakeTime.morning79,
      sleepTime: SleepTime.midnight231,
      chronotype: Chronotype.middle,
      workHours: WorkHours.nineToSix,
      commuteTime: CommuteTime.under30,
      mealPattern: MealPattern.regular3,
      exercisePreferredTime: ExercisePreferredTime.evening,
      goalFocus: GoalFocus.workStudy,
      pastWeekContext: pastWeekContext,
      fixedSchedules: fixedSchedules,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('WeeklyWizardService.generate (Path A — rule-based 기본)', () {
    late _MockApiClient client;
    late _MockAggregator aggregator;
    late WeeklyWizardService service;

    final answers = _sampleAnswers();
    final weekStart = DateTime(2026, 4, 20);

    setUp(() {
      client = _MockApiClient();
      aggregator = _MockAggregator();
      service = WeeklyWizardService(client, aggregator);
      when(
        () => aggregator.pastWeekContext(
          userId: any(named: 'userId'),
          weeks: any(named: 'weeks'),
        ),
      ).thenAnswer((_) async => null);
    });

    test('LLM 호출 0건 — apiClient.post() 미호출', () async {
      await service.generate(answers: answers, weekStart: weekStart);
      verifyNever(() => client.post(any(), body: any(named: 'body')));
    });

    test('source = WizardSource.rule, items 10~18 범위', () async {
      final result =
          await service.generate(answers: answers, weekStart: weekStart);
      expect(result.source, WizardSource.rule);
      expect(result.items.length, inInclusiveRange(10, 18));
    });

    test('빈 existingThisWeek → conflicts 에 EXISTING_OVERLAP 0건', () async {
      final result =
          await service.generate(answers: answers, weekStart: weekStart);
      expect(
        result.conflicts.where(
          (c) => c.kind == ConflictKind.existingOverlap,
        ),
        isEmpty,
      );
    });

    test('기존 schedules 와 겹치면 EXISTING_OVERLAP 첨부', () async {
      // Path A 가 만드는 슬롯 중 한 곳을 노린 가짜 기존 일정
      final existing = [
        (
          id: 99,
          start: DateTime(2026, 4, 20, 9, 30),
          end: DateTime(2026, 4, 20, 10, 30),
        ),
      ];
      final result = await service.generate(
        answers: answers,
        weekStart: weekStart,
        existingThisWeek: existing,
      );
      expect(
        result.conflicts.where(
          (c) => c.kind == ConflictKind.existingOverlap,
        ),
        isNotEmpty,
      );
    });

    test('fixedSchedules 파싱 실패 → warnings 누적', () async {
      final result = await service.generate(
        answers: _sampleAnswers(fixedSchedules: '오후 3시 회의'),
        weekStart: weekStart,
      );
      expect(result.warnings, isNotEmpty);
    });

    test('userId 제공 + pastWeekContext 주입 → planner 가 보정', () async {
      const ctx = PastWeekContext(
        weeklyCompletionRate: 0.3,
        focusRatioAvg: 0.4,
        weeksObserved: 4,
      );
      when(
        () => aggregator.pastWeekContext(
          userId: 'u1',
          weeks: any(named: 'weeks'),
        ),
      ).thenAnswer((_) async => ctx);

      final result = await service.generate(
        answers: answers,
        weekStart: weekStart,
        userId: 'u1',
      );
      // 보정 후 items 가 줄어듦 (단순히 응답은 받음)
      expect(result.items, isNotEmpty);
      expect(result.source, WizardSource.rule);
    });

    test('userId 없음 → aggregator 미호출', () async {
      await service.generate(answers: answers, weekStart: weekStart);
      verifyNever(
        () => aggregator.pastWeekContext(
          userId: any(named: 'userId'),
          weeks: any(named: 'weeks'),
        ),
      );
    });
  });

  group('WeeklyWizardService.refine (LLM 단발 — Issue 07 에서 multi-turn)', () {
    late _MockApiClient client;
    late _MockAggregator aggregator;
    late WeeklyWizardService service;

    final answers = _sampleAnswers();
    final weekStart = DateTime(2026, 4, 20);

    const previousItems = <GeneratedScheduleItem>[
      GeneratedScheduleItem(
        title: '러닝',
        dayOfWeek: 2,
        startTime: '06:30',
        endTime: '07:15',
        category: ScheduleCategory.health,
      ),
    ];

    const followupAnswers = <String, String>{
      'focus-intensity': 'h2',
      'exercise-strength': 'mid',
    };

    final emptySession = RefinementSession(
      conversationId: 'conv-1',
      history: [
        RefinementTurn(
          turn: 1,
          items: previousItems,
          followupAnswers: const {},
          timestamp: DateTime(2026, 4, 20, 10),
        ),
      ],
    );

    setUp(() {
      client = _MockApiClient();
      aggregator = _MockAggregator();
      service = WeeklyWizardService(client, aggregator);
      when(
        () => aggregator.pastWeekContext(
          userId: any(named: 'userId'),
          weeks: any(named: 'weeks'),
        ),
      ).thenAnswer((_) async => null);
    });

    test('refine body 에 mode/previous_turns/conversation_id/turn/followup', () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'items': <Map<String, dynamic>>[],
            'source': 'llm',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      await service.refine(
        answers: answers,
        weekStart: weekStart,
        session: emptySession,
        followupAnswers: followupAnswers,
      );

      final captured =
          verify(() => client.post(any(), body: captureAny(named: 'body')))
              .captured
              .single as Map<String, dynamic>;
      expect(captured['mode'], 'refine');
      expect(captured['conversation_id'], 'conv-1');
      expect(captured['turn'], 2);
      expect(captured['previous_turns'], isA<List<dynamic>>());
      expect(captured['followup_answers'], followupAnswers);
    });

    test('LLM 응답 파싱 → source=llm, items 매핑', () async {
      final bodyJson = jsonEncode({
        'items': [
          {
            'title': '독서',
            'day_of_week': 3,
            'start_time': '20:00',
            'end_time': '21:00',
            'category': 'study',
            'tags': <String>[],
          },
        ],
        'source': 'llm',
      });
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          bodyJson,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final result = await service.refine(
        answers: answers,
        weekStart: weekStart,
        session: emptySession,
        followupAnswers: followupAnswers,
      );

      expect(result.source, WizardSource.llm);
      expect(result.items, hasLength(1));
      expect(result.items.first.title, '독서');
    });

    test('5xx → preset 폴백 (Issue 06 에서 retry 추가 예정)', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final result = await service.refine(
        answers: answers,
        weekStart: weekStart,
        session: emptySession,
        followupAnswers: followupAnswers,
      );

      expect(result.source, WizardSource.preset);
      expect(result.items, isEmpty);
    });

    test('네트워크 예외 → preset 폴백', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(Exception('network down'));

      final result = await service.refine(
        answers: answers,
        weekStart: weekStart,
        session: emptySession,
        followupAnswers: followupAnswers,
      );

      expect(result.source, WizardSource.preset);
      expect(result.items, isEmpty);
    });
  });

  group('WeeklyWizardService.enhance (Path B — LLM enhance, 3-retry §9.3)', () {
    late _MockApiClient client;
    late _MockAggregator aggregator;
    late WeeklyWizardService service;

    final answers = _sampleAnswers();
    final weekStart = DateTime(2026, 4, 20);

    const seed = <GeneratedScheduleItem>[
      GeneratedScheduleItem(
        title: '딥 포커스',
        dayOfWeek: 0,
        startTime: '09:00',
        endTime: '10:30',
        category: ScheduleCategory.work,
      ),
    ];

    setUp(() {
      client = _MockApiClient();
      aggregator = _MockAggregator();
      // sleep 스텁: 즉시 반환 (테스트 가속)
      service = WeeklyWizardService(
        client,
        aggregator,
        sleep: (_) async {},
      );
      when(
        () => aggregator.pastWeekContext(
          userId: any(named: 'userId'),
          weeks: any(named: 'weeks'),
        ),
      ).thenAnswer((_) async => null);
    });

    test('mode=enhance + rule_based_seed + objective + conversation_id 포함',
        () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'items': [
              {
                'title': '강화된 딥 포커스',
                'day_of_week': 0,
                'start_time': '09:00',
                'end_time': '10:30',
                'category': 'work',
                'tags': <String>[],
              },
            ],
            'source': 'llm',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
        conversationId: 'c1',
      );

      final captured =
          verify(() => client.post(any(), body: captureAny(named: 'body')))
              .captured
              .single as Map<String, dynamic>;
      expect(captured['mode'], 'enhance');
      expect(captured['enhance_objective'], 'diversify_titles');
      expect(captured['conversation_id'], 'c1');
      expect(captured['turn'], 1);
      expect(captured['rule_based_seed'], isA<List<dynamic>>());
    });

    test('정상 LLM 응답 → source=llm, items 매핑', () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'items': [
              {
                'title': '강화된 딥 포커스',
                'day_of_week': 0,
                'start_time': '09:00',
                'end_time': '10:30',
                'category': 'work',
                'tags': <String>[],
              },
            ],
            'source': 'llm',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.rebalanceLoad,
      );
      expect(result.source, WizardSource.llm);
      expect(result.items.first.title, '강화된 딥 포커스');
    });

    test('5xx 3회 연속 → seed 폴백 (3 retry)', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
      );
      verify(() => client.post(any(), body: any(named: 'body'))).called(3);
      expect(result.items, equals(seed));
      expect(result.source, WizardSource.rule);
      expect(result.warnings.first, contains('enhance 실패'));
    });

    test('4xx → 즉시 폴백 (재시도 0)', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Bad Request', 400));

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
      );
      verify(() => client.post(any(), body: any(named: 'body'))).called(1);
      expect(result.items, equals(seed));
      expect(result.source, WizardSource.rule);
    });

    test('timeout 3회 → seed 폴백', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(TimeoutException('timeout'));

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
      );
      verify(() => client.post(any(), body: any(named: 'body'))).called(3);
      expect(result.items, equals(seed));
    });

    test('parse 실패 3회 → seed 폴백', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('not json', 200));

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
      );
      verify(() => client.post(any(), body: any(named: 'body'))).called(3);
      expect(result.items, equals(seed));
    });

    test('items.isEmpty 3회 → seed 폴백', () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'items': <Map<String, dynamic>>[], 'source': 'llm'}),
          200,
        ),
      );

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
      );
      verify(() => client.post(any(), body: any(named: 'body'))).called(3);
      expect(result.items, equals(seed));
    });

    test('첫 번째 5xx → 두 번째 200 → 정상 응답 (1 retry)', () async {
      var calls = 0;
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async {
          calls++;
          if (calls == 1) return http.Response('Server Error', 500);
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'title': '회복',
                  'day_of_week': 1,
                  'start_time': '20:00',
                  'end_time': '21:00',
                  'category': 'health',
                  'tags': <String>[],
                },
              ],
              'source': 'llm',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        },
      );

      final result = await service.enhance(
        answers: answers,
        weekStart: weekStart,
        seed: seed,
        objective: EnhanceObjective.diversifyTitles,
      );
      verify(() => client.post(any(), body: any(named: 'body'))).called(2);
      expect(result.source, WizardSource.llm);
      expect(result.items.first.title, '회복');
    });
  });
}

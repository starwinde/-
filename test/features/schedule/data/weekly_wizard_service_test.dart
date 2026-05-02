import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/ai/data/report_aggregator.dart';
import 'package:routinemon/features/schedule/data/weekly_wizard_service.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockAggregator extends Mock implements ReportAggregator {}

WizardAnswers _sampleAnswers({
  PastWeekContext? pastWeekContext,
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
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('WeeklyWizardService.generate', () {
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

    test('posts to /webhook/routinemon/weekly-wizard and parses LLM response',
        () async {
      final bodyJson = jsonEncode({
        'items': [
          {
            'title': '러닝',
            'day_of_week': 2,
            'start_time': '06:30',
            'end_time': '07:15',
            'category': 'health',
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

      final result =
          await service.generate(answers: answers, weekStart: weekStart);

      expect(result.source, WizardSource.llm);
      expect(result.items, hasLength(1));
      expect(result.items.first.title, '러닝');
      verify(() => client.post(
            '/webhook/routinemon/weekly-wizard',
            body: {
              'answers': answers.toJson(),
              'week_start': '2026-04-20',
            },
          )).called(1);
    });

    test('injects pastWeekContext from aggregator when userId is provided',
        () async {
      const ctx = PastWeekContext(
        weeklyCompletionRate: 0.42,
        lowestCompletionCategory: 'study',
        mostMissedTimeBlock: 'evening',
        focusRatioAvg: 0.55,
        weeksObserved: 4,
      );
      when(
        () => aggregator.pastWeekContext(
          userId: 'u1',
          weeks: any(named: 'weeks'),
        ),
      ).thenAnswer((_) async => ctx);
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'items': <Map<String, dynamic>>[], 'source': 'llm'}),
          200,
        ),
      );

      await service.generate(
        answers: answers,
        weekStart: weekStart,
        userId: 'u1',
      );

      final captured =
          verify(() => client.post(any(), body: captureAny(named: 'body')))
              .captured
              .single as Map<String, dynamic>;
      final answersJson = captured['answers'] as Map<String, dynamic>;
      final pastJson = answersJson['past_week_context'] as Map<String, dynamic>;
      expect(pastJson['weekly_completion_rate'], 0.42);
      expect(pastJson['lowest_completion_category'], 'study');
      expect(pastJson['most_missed_time_block'], 'evening');
      expect(pastJson['weeks_observed'], 4);
    });

    test('does not call aggregator when userId is null', () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'items': <Map<String, dynamic>>[], 'source': 'llm'}),
          200,
        ),
      );

      await service.generate(answers: answers, weekStart: weekStart);

      verifyNever(
        () => aggregator.pastWeekContext(
          userId: any(named: 'userId'),
          weeks: any(named: 'weeks'),
        ),
      );
    });

    test('returns preset fallback on non-2xx status', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final result =
          await service.generate(answers: answers, weekStart: weekStart);

      expect(result.source, WizardSource.preset);
      expect(result.items, isEmpty);
    });

    test('returns preset fallback on JSON parse failure', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('not json', 200));

      final result =
          await service.generate(answers: answers, weekStart: weekStart);

      expect(result.source, WizardSource.preset);
    });

    test('returns preset fallback on network exception', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(Exception('network down'));

      final result =
          await service.generate(answers: answers, weekStart: weekStart);

      expect(result.source, WizardSource.preset);
    });
  });

  group('WeeklyWizardService.refine', () {
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

    test('posts body with refinement key containing previous_items + '
        'followup_answers', () async {
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
        previousItems: previousItems,
        followupAnswers: followupAnswers,
      );

      verify(() => client.post(
            '/webhook/routinemon/weekly-wizard',
            body: {
              'answers': answers.toJson(),
              'week_start': '2026-04-20',
              'refinement': {
                'previous_items': [previousItems.first.toJson()],
                'followup_answers': followupAnswers,
              },
            },
          )).called(1);
    });

    test('parses response items correctly', () async {
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
        previousItems: previousItems,
        followupAnswers: followupAnswers,
      );

      expect(result.source, WizardSource.llm);
      expect(result.items, hasLength(1));
      expect(result.items.first.title, '독서');
      expect(result.items.first.category, ScheduleCategory.study);
    });

    test('returns preset on non-2xx', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final result = await service.refine(
        answers: answers,
        weekStart: weekStart,
        previousItems: previousItems,
        followupAnswers: followupAnswers,
      );

      expect(result.source, WizardSource.preset);
      expect(result.items, isEmpty);
    });

    test('returns preset on exception', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(Exception('network down'));

      final result = await service.refine(
        answers: answers,
        weekStart: weekStart,
        previousItems: previousItems,
        followupAnswers: followupAnswers,
      );

      expect(result.source, WizardSource.preset);
      expect(result.items, isEmpty);
    });
  });
}

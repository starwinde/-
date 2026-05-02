import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

void main() {
  group('AutoScheduleRequest', () {
    test('toJson has snake_case keys', () {
      const req = AutoScheduleRequest(
        text: '내일 오후 2시 팀 미팅',
        userLocale: 'ko',
      );
      expect(req.toJson(), {
        'text': '내일 오후 2시 팀 미팅',
        'user_locale': 'ko',
      });
    });
  });

  group('AutoScheduleResponse', () {
    test('fromJson parses LLM response with all fields', () {
      final json = <String, dynamic>{
        'title': '팀 미팅',
        'start_time': '2026-04-19T14:00:00+09:00',
        'end_time': '2026-04-19T15:00:00+09:00',
        'category': 'work',
        'tags': ['meeting', 'team'],
        'confidence': 0.85,
        'source': 'llm',
      };
      final res = AutoScheduleResponse.fromJson(json);
      expect(res.title, '팀 미팅');
      expect(res.startTime, DateTime.parse('2026-04-19T14:00:00+09:00'));
      expect(res.category, ScheduleCategory.work);
      expect(res.tags, ['meeting', 'team']);
      expect(res.confidence, 0.85);
      expect(res.source, AutoScheduleSource.llm);
    });

    test('fromJson parses preset fallback with null times', () {
      final json = <String, dynamic>{
        'title': '일정',
        'start_time': null,
        'end_time': null,
        'category': 'etc',
        'tags': <String>[],
        'confidence': 0.0,
        'source': 'preset',
      };
      final res = AutoScheduleResponse.fromJson(json);
      expect(res.startTime, isNull);
      expect(res.endTime, isNull);
      expect(res.category, ScheduleCategory.etc);
      expect(res.source, AutoScheduleSource.preset);
    });

    test('fromJson falls back to etc for unknown category', () {
      final json = <String, dynamic>{
        'title': 'x',
        'start_time': null,
        'end_time': null,
        'category': 'unknown_category',
        'tags': <String>[],
        'confidence': 0.1,
        'source': 'llm',
      };
      final res = AutoScheduleResponse.fromJson(json);
      expect(res.category, ScheduleCategory.etc);
    });

    test('needsUserConfirmation is true when confidence < 0.5', () {
      const low = AutoScheduleResponse(
        title: 't',
        startTime: null,
        endTime: null,
        category: ScheduleCategory.etc,
        tags: [],
        confidence: 0.3,
        source: AutoScheduleSource.llm,
      );
      final high = low.copyWith(confidence: 0.7);
      expect(low.needsUserConfirmation, isTrue);
      expect(high.needsUserConfirmation, isFalse);
    });
  });
}

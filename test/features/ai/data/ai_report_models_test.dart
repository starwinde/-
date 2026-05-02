import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

void main() {
  group('AiReportRequest', () {
    test('toJson has snake_case keys', () {
      final req = AiReportRequest(
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
      final json = req.toJson();
      expect(json['period'], 'weekly');
      expect(json['user_id'], 'u1');
      expect(json['user_locale'], 'ko');
      expect((json['data'] as Map<String, dynamic>)['focus_sessions'], 10);
      expect((json['data'] as Map<String, dynamic>)['avg_focus_ratio'], 0.75);
    });
  });

  group('AiReportResponse', () {
    test('fromJson parses llm source', () {
      final json = {
        'summary': '이번 주 집중도 우수',
        'insights': ['a', 'b'],
        'suggestions': ['c'],
        'encouragement': '잘하고 있어요!',
        'source': 'llm',
      };
      final res = AiReportResponse.fromJson(json);
      expect(res.source, AiReportSource.llm);
      expect(res.insights, ['a', 'b']);
    });

    test('fromJson parses preset fallback', () {
      final json = {
        'summary': '',
        'insights': <String>[],
        'suggestions': <String>[],
        'encouragement': '',
        'source': 'preset',
      };
      final res = AiReportResponse.fromJson(json);
      expect(res.source, AiReportSource.preset);
    });
  });
}

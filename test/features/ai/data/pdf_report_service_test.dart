import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/ai/data/pdf_report_models.dart';
import 'package:routinemon/features/ai/data/pdf_report_service.dart';

void main() {
  late PdfReportService service;

  const baseReport = AiReportResponse(
    summary: '이번 주 집중도 우수.',
    insights: ['오전 집중도가 가장 높습니다'],
    suggestions: ['수요일 알람을 30분 앞당겨 보세요'],
    encouragement: '꾸준한 흐름이 멋져요!',
    source: AiReportSource.llm,
  );

  const baseReq = PdfReportRequest(
    userId: 'u1',
    period: ReportPeriod.weekly,
    report: baseReport,
    meta: PdfReportMeta(
      petName: '두두',
      userName: '민수',
      periodLabel: '4월 19일~25일',
    ),
  );

  setUp(() {
    service = PdfReportService();
  });

  test('renders a non-empty PDF starting with %PDF magic bytes', () async {
    final bytes = await service.render(baseReq);
    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(100));
    expect(bytes.sublist(0, 4), equals([0x25, 0x50, 0x44, 0x46]));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('renders preset-source report without insights/suggestions', () async {
    const presetReq = PdfReportRequest(
      userId: 'u1',
      period: ReportPeriod.monthly,
      report: AiReportResponse(
        summary: '데이터가 부족합니다.',
        insights: <String>[],
        suggestions: <String>[],
        encouragement: '',
        source: AiReportSource.preset,
      ),
    );
    final bytes = await service.render(presetReq);
    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(100));
  }, timeout: const Timeout(Duration(seconds: 30)));
}

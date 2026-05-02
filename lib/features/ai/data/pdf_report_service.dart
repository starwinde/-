import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/ai/data/pdf_report_models.dart';

part 'pdf_report_service.g.dart';

/// Renders a [AiReportResponse] into a PDF on-device. Replaces the previous
/// n8n+Puppeteer HTML→PDF workflow — n8n LangChain redesign keeps server-side
/// concerns in the OpenAI Chat Model node only; presentation lives in the
/// client.
class PdfReportService {
  /// Creates a service. No external dependencies — fully client-side.
  PdfReportService();

  /// Renders [req] into A4 PDF bytes. Returns `null` on any failure so the
  /// UI can show a generic error and let the user retry.
  Future<Uint8List?> render(PdfReportRequest req) async {
    try {
      final font = await PdfGoogleFonts.notoSansKRRegular();
      final fontBold = await PdfGoogleFonts.notoSansKRBold();
      final theme = pw.ThemeData.withFont(base: font, bold: fontBold);
      final doc = pw.Document(theme: theme);
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => _buildContent(req),
        ),
      );
      return doc.save();
    } on Exception {
      return null;
    }
  }

  List<pw.Widget> _buildContent(PdfReportRequest req) {
    final report = req.report;
    final meta = req.meta;
    final periodTitle = req.period == ReportPeriod.weekly
        ? '주간 AI 리포트'
        : '월간 AI 리포트';
    return [
      pw.Header(
        level: 0,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              periodTitle,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            if (meta?.periodLabel != null && meta!.periodLabel!.isNotEmpty)
              pw.Text(
                meta.periodLabel!,
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            if (meta?.petName != null && meta!.petName!.isNotEmpty)
              pw.Text(
                '동반 펫: ${meta.petName}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),
      _card(title: '요약', body: report.summary),
      if (report.insights.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        _bulletSection(title: '인사이트', items: report.insights),
      ],
      if (report.suggestions.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        _bulletSection(title: '다음 주기 제안', items: report.suggestions),
      ],
      if (report.encouragement.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        _card(title: '응원 메시지', body: report.encouragement, accent: true),
      ],
      pw.SizedBox(height: 24),
      pw.Text(
        report.source == AiReportSource.llm
            ? '출처: 로컬 LLM (LM Studio · gemma-4-e4b)'
            : '출처: 프리셋 폴백',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    ];
  }

  pw.Widget _card({
    required String title,
    required String body,
    bool accent = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: accent ? PdfColors.amber50 : PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(body, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _bulletSection({
    required String title,
    required List<String> items,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        for (final item in items)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Provides [PdfReportService]. Stateless — singleton-equivalent.
@riverpod
PdfReportService pdfReportService(Ref ref) => PdfReportService();

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/ai/data/ai_report_service.dart';
import 'package:routinemon/features/ai/data/pdf_report_models.dart';
import 'package:routinemon/features/ai/data/pdf_report_service.dart';
import 'package:routinemon/features/ai/data/report_aggregator.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/auth/application/user_id_migrator.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';

/// AI 리포트 페이지. 사용자가 먼저 기간(주/월)을 선택하고, 선택한 범위로
/// LLM 리포트를 생성한 뒤 PDF로 내보낼 수 있다. 입력 데이터는
/// [ReportAggregator]가 Drift에서 집계한 작성/이행/체크 3축 메트릭이다.
class AiReportPage extends ConsumerStatefulWidget {
  /// Creates the AI report page.
  const AiReportPage({super.key, this.period = ReportPeriod.weekly});

  /// Report period — defaults to weekly. Routes can pass monthly via
  /// `extra` if needed.
  final ReportPeriod period;

  @override
  ConsumerState<AiReportPage> createState() => _AiReportPageState();
}

class _AiReportPageState extends ConsumerState<AiReportPage> {
  AiReportResponse? _report;
  DateTimeRange? _selectedRange;
  bool _loading = false;
  bool _exporting = false;
  String? _error;

  List<DateTimeRange> _availableRanges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (widget.period == ReportPeriod.weekly) {
      // Mon~Sun 단위, 이번 주부터 4주 전까지 (총 5개)
      final currentMonday = today.subtract(Duration(days: today.weekday - 1));
      return List.generate(5, (i) {
        final start = currentMonday.subtract(Duration(days: 7 * i));
        final end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return DateTimeRange(start: start, end: end);
      });
    }
    // 월 단위, 이번 달부터 3개월 전까지 (총 4개)
    return List.generate(4, (i) {
      final monthStart = DateTime(now.year, now.month - i);
      final monthEnd = DateTime(
        now.year,
        now.month - i + 1,
      ).subtract(const Duration(seconds: 1));
      return DateTimeRange(start: monthStart, end: monthEnd);
    });
  }

  String _rangeLabel(DateTimeRange r, int index) {
    if (widget.period == ReportPeriod.weekly) {
      final base = index == 0
          ? '이번 주'
          : index == 1
          ? '지난 주'
          : '$index주 전';
      return '$base · ${_formatDate(r.start)} ~ ${_formatDate(r.end)}';
    }
    final base = index == 0
        ? '이번 달'
        : index == 1
        ? '지난 달'
        : '$index달 전';
    return '$base · ${r.start.year}년 ${r.start.month}월';
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _periodLabel() {
    final r = _selectedRange;
    if (r == null) return '';
    return '${_formatDate(r.start)} ~ ${_formatDate(r.end)}';
  }

  String _resolveUserId() {
    final authState = ref.read(authProvider);
    return authState.maybeWhen(
      data: (user) => user?.id ?? guestUserId,
      orElse: () => guestUserId,
    );
  }

  Future<String?> _resolveActivePetName(String userId) async {
    try {
      final repo = ref.read(petRepositoryProvider);
      final pet = await repo.getActivePet(userId);
      final name = pet?.name.trim();
      return (name == null || name.isEmpty) ? null : name;
    } on Object {
      return null;
    }
  }

  Future<AiReportRequest> _buildRequest(DateTimeRange range) async {
    final userId = _resolveUserId();
    final data = await ref
        .read(reportAggregatorProvider)
        .aggregate(userId: userId, range: range);
    return AiReportRequest(
      userId: userId,
      period: widget.period,
      periodStart: range.start,
      periodEnd: range.end,
      data: data,
      userLocale: 'ko',
    );
  }

  Future<void> _generate(DateTimeRange range) async {
    setState(() {
      _selectedRange = range;
      _loading = true;
      _error = null;
      _report = null;
    });
    try {
      final req = await _buildRequest(range);
      final res = await ref.read(aiReportServiceProvider).generate(req);
      if (!mounted) return;
      setState(() => _report = res);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetSelection() {
    setState(() {
      _report = null;
      _selectedRange = null;
      _error = null;
    });
  }

  Future<void> _downloadPdf() async {
    final report = _report;
    if (report == null) return;
    setState(() => _exporting = true);
    try {
      final userId = _resolveUserId();
      final petName = await _resolveActivePetName(userId);
      final req = PdfReportRequest(
        userId: userId,
        period: widget.period,
        report: report,
        meta: PdfReportMeta(petName: petName, periodLabel: _periodLabel()),
      );
      final bytes = await ref.read(pdfReportServiceProvider).render(req);
      if (!mounted) return;
      if (bytes == null) {
        setState(() => _error = 'PDF 생성에 실패했어요. n8n 서버를 확인해 주세요.');
        return;
      }
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'routinemon-${widget.period.name}-report.pdf',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.period == ReportPeriod.weekly
        ? '주간 AI 리포트'
        : '월간 AI 리포트';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_selectedRange != null && !_loading)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: '다른 기간 선택',
              onPressed: _resetSelection,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _report == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _exporting ? null : _downloadPdf,
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_exporting ? '생성 중…' : 'PDF 다운로드'),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedRange == null) {
      return _buildSelector();
    }
    final report = _report;
    if (report == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? '리포트를 생성할 수 없어요.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _generate(_selectedRange!),
                child: const Text('다시 시도'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _resetSelection,
                child: const Text('다른 기간 선택'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Text(_periodLabel(), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              report.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        if (report.insights.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('인사이트', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final s in report.insights)
            ListTile(
              dense: true,
              leading: const Icon(Icons.lightbulb_outline, size: 18),
              title: Text(s),
            ),
        ],
        if (report.suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('다음 주기 제안', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final s in report.suggestions)
            ListTile(
              dense: true,
              leading: const Icon(Icons.trending_up, size: 18),
              title: Text(s),
            ),
        ],
        if (report.encouragement.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                report.encouragement,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          report.source == AiReportSource.llm
              ? '출처: 로컬 LLM (n8n)'
              : '출처: 프리셋 폴백',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSelector() {
    final ranges = _availableRanges();
    final unit = widget.period == ReportPeriod.weekly ? '주' : '월';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '리포트 기간을 선택해 주세요',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '선택한 $unit의 데이터로 AI가 요약을 만들어요.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < ranges.length; i++)
          Card(
            child: ListTile(
              leading: Icon(
                widget.period == ReportPeriod.weekly
                    ? Icons.calendar_view_week
                    : Icons.calendar_month,
              ),
              title: Text(_rangeLabel(ranges[i], i)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _generate(ranges[i]),
            ),
          ),
      ],
    );
  }
}

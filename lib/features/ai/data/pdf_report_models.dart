// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

part 'pdf_report_models.freezed.dart';
part 'pdf_report_models.g.dart';

/// Optional metadata embedded in the PDF header (pet name, user name,
/// human-readable period range).
@freezed
sealed class PdfReportMeta with _$PdfReportMeta {
  /// Creates a metadata payload for the PDF header.
  const factory PdfReportMeta({
    @JsonKey(name: 'pet_name') String? petName,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'period_label') String? periodLabel,
  }) = _PdfReportMeta;

  /// Parses JSON into [PdfReportMeta].
  factory PdfReportMeta.fromJson(Map<String, dynamic> json) =>
      _$PdfReportMetaFromJson(json);
}

/// Request body sent to n8n `routinemon-pdf-report` webhook. Wraps an
/// already-generated [AiReportResponse] with rendering metadata.
@freezed
sealed class PdfReportRequest with _$PdfReportRequest {
  /// Creates a PDF render request.
  const factory PdfReportRequest({
    @JsonKey(name: 'user_id') required String userId,
    required ReportPeriod period,
    required AiReportResponse report,
    PdfReportMeta? meta,
  }) = _PdfReportRequest;

  /// Parses JSON into [PdfReportRequest].
  factory PdfReportRequest.fromJson(Map<String, dynamic> json) =>
      _$PdfReportRequestFromJson(json);
}

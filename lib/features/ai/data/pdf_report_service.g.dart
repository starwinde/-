// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_report_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [PdfReportService]. Stateless — singleton-equivalent.

@ProviderFor(pdfReportService)
final pdfReportServiceProvider = PdfReportServiceProvider._();

/// Provides [PdfReportService]. Stateless — singleton-equivalent.

final class PdfReportServiceProvider
    extends
        $FunctionalProvider<
          PdfReportService,
          PdfReportService,
          PdfReportService
        >
    with $Provider<PdfReportService> {
  /// Provides [PdfReportService]. Stateless — singleton-equivalent.
  PdfReportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pdfReportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pdfReportServiceHash();

  @$internal
  @override
  $ProviderElement<PdfReportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PdfReportService create(Ref ref) {
    return pdfReportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PdfReportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PdfReportService>(value),
    );
  }
}

String _$pdfReportServiceHash() => r'd0efdb9cb7874bb732238916e1336ceed18e0a27';

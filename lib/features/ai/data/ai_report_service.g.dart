// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_report_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [AiReportService] wired to the global [ApiClient].

@ProviderFor(aiReportService)
final aiReportServiceProvider = AiReportServiceProvider._();

/// Provides [AiReportService] wired to the global [ApiClient].

final class AiReportServiceProvider
    extends
        $FunctionalProvider<AiReportService, AiReportService, AiReportService>
    with $Provider<AiReportService> {
  /// Provides [AiReportService] wired to the global [ApiClient].
  AiReportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiReportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiReportServiceHash();

  @$internal
  @override
  $ProviderElement<AiReportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiReportService create(Ref ref) {
    return aiReportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiReportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiReportService>(value),
    );
  }
}

String _$aiReportServiceHash() => r'b9728cad21e4af0038363991a800c4586dcc7dd9';

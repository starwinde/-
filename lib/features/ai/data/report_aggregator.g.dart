// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_aggregator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [ReportAggregator] wired to the global [AppDatabase].

@ProviderFor(reportAggregator)
final reportAggregatorProvider = ReportAggregatorProvider._();

/// Provides [ReportAggregator] wired to the global [AppDatabase].

final class ReportAggregatorProvider
    extends
        $FunctionalProvider<
          ReportAggregator,
          ReportAggregator,
          ReportAggregator
        >
    with $Provider<ReportAggregator> {
  /// Provides [ReportAggregator] wired to the global [AppDatabase].
  ReportAggregatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportAggregatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportAggregatorHash();

  @$internal
  @override
  $ProviderElement<ReportAggregator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReportAggregator create(Ref ref) {
    return reportAggregator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportAggregator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportAggregator>(value),
    );
  }
}

String _$reportAggregatorHash() => r'58e48c14b0e392cbd1e7d558e6f0d133af089911';

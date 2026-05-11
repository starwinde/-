// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wizard_analytics_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider — overridden in tests with a recording NoOp.

@ProviderFor(wizardAnalyticsService)
final wizardAnalyticsServiceProvider = WizardAnalyticsServiceProvider._();

/// Riverpod provider — overridden in tests with a recording NoOp.

final class WizardAnalyticsServiceProvider
    extends
        $FunctionalProvider<
          WizardAnalyticsService,
          WizardAnalyticsService,
          WizardAnalyticsService
        >
    with $Provider<WizardAnalyticsService> {
  /// Riverpod provider — overridden in tests with a recording NoOp.
  WizardAnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wizardAnalyticsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wizardAnalyticsServiceHash();

  @$internal
  @override
  $ProviderElement<WizardAnalyticsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WizardAnalyticsService create(Ref ref) {
    return wizardAnalyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WizardAnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WizardAnalyticsService>(value),
    );
  }
}

String _$wizardAnalyticsServiceHash() =>
    r'432f19ee1399e0dd6c62184e54228cbde3e8bc89';

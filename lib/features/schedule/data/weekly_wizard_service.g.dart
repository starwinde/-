// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_wizard_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [WeeklyWizardService] wired to the global [ApiClient] and
/// [ReportAggregator].

@ProviderFor(weeklyWizardService)
final weeklyWizardServiceProvider = WeeklyWizardServiceProvider._();

/// Provides [WeeklyWizardService] wired to the global [ApiClient] and
/// [ReportAggregator].

final class WeeklyWizardServiceProvider
    extends
        $FunctionalProvider<
          WeeklyWizardService,
          WeeklyWizardService,
          WeeklyWizardService
        >
    with $Provider<WeeklyWizardService> {
  /// Provides [WeeklyWizardService] wired to the global [ApiClient] and
  /// [ReportAggregator].
  WeeklyWizardServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyWizardServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyWizardServiceHash();

  @$internal
  @override
  $ProviderElement<WeeklyWizardService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeeklyWizardService create(Ref ref) {
    return weeklyWizardService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeeklyWizardService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeeklyWizardService>(value),
    );
  }
}

String _$weeklyWizardServiceHash() =>
    r'02aeeef5482a356235a742ff2ddeb311c8f41b8e';

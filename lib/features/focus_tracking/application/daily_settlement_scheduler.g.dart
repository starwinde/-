// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_settlement_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the daily settlement scheduler.

@ProviderFor(dailySettlementScheduler)
final dailySettlementSchedulerProvider = DailySettlementSchedulerProvider._();

/// Provides the daily settlement scheduler.

final class DailySettlementSchedulerProvider
    extends
        $FunctionalProvider<
          DailySettlementScheduler,
          DailySettlementScheduler,
          DailySettlementScheduler
        >
    with $Provider<DailySettlementScheduler> {
  /// Provides the daily settlement scheduler.
  DailySettlementSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailySettlementSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailySettlementSchedulerHash();

  @$internal
  @override
  $ProviderElement<DailySettlementScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DailySettlementScheduler create(Ref ref) {
    return dailySettlementScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailySettlementScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailySettlementScheduler>(value),
    );
  }
}

String _$dailySettlementSchedulerHash() =>
    r'46b7317e5e90585cec3ab053440aff6af6970713';

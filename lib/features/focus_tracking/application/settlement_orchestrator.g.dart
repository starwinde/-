// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_orchestrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [SettlementOrchestrator].

@ProviderFor(settlementOrchestrator)
final settlementOrchestratorProvider = SettlementOrchestratorProvider._();

/// Provides the [SettlementOrchestrator].

final class SettlementOrchestratorProvider
    extends
        $FunctionalProvider<
          SettlementOrchestrator,
          SettlementOrchestrator,
          SettlementOrchestrator
        >
    with $Provider<SettlementOrchestrator> {
  /// Provides the [SettlementOrchestrator].
  SettlementOrchestratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settlementOrchestratorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settlementOrchestratorHash();

  @$internal
  @override
  $ProviderElement<SettlementOrchestrator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettlementOrchestrator create(Ref ref) {
    return settlementOrchestrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettlementOrchestrator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettlementOrchestrator>(value),
    );
  }
}

String _$settlementOrchestratorHash() =>
    r'a90c257078e825f3a1086be93fdd7a3874e43972';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_interaction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider.

@ProviderFor(petInteractionRepository)
final petInteractionRepositoryProvider = PetInteractionRepositoryProvider._();

/// Riverpod provider.

final class PetInteractionRepositoryProvider
    extends
        $FunctionalProvider<
          PetInteractionRepository,
          PetInteractionRepository,
          PetInteractionRepository
        >
    with $Provider<PetInteractionRepository> {
  /// Riverpod provider.
  PetInteractionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petInteractionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petInteractionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PetInteractionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PetInteractionRepository create(Ref ref) {
    return petInteractionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PetInteractionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PetInteractionRepository>(value),
    );
  }
}

String _$petInteractionRepositoryHash() =>
    r'c98d33fcccb2513aa0befdd952b6562ae8cadf71';

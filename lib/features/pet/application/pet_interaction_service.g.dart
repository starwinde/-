// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_interaction_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider.

@ProviderFor(petInteractionService)
final petInteractionServiceProvider = PetInteractionServiceProvider._();

/// Riverpod provider.

final class PetInteractionServiceProvider
    extends
        $FunctionalProvider<
          PetInteractionService,
          PetInteractionService,
          PetInteractionService
        >
    with $Provider<PetInteractionService> {
  /// Riverpod provider.
  PetInteractionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petInteractionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petInteractionServiceHash();

  @$internal
  @override
  $ProviderElement<PetInteractionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PetInteractionService create(Ref ref) {
    return petInteractionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PetInteractionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PetInteractionService>(value),
    );
  }
}

String _$petInteractionServiceHash() =>
    r'4956eb398adade7f31c363805692434d41e0cca6';

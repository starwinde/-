// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [PetRepository] backed by the app database.

@ProviderFor(petRepository)
final petRepositoryProvider = PetRepositoryProvider._();

/// Provides the [PetRepository] backed by the app database.

final class PetRepositoryProvider
    extends $FunctionalProvider<PetRepository, PetRepository, PetRepository>
    with $Provider<PetRepository> {
  /// Provides the [PetRepository] backed by the app database.
  PetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petRepositoryHash();

  @$internal
  @override
  $ProviderElement<PetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PetRepository create(Ref ref) {
    return petRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PetRepository>(value),
    );
  }
}

String _$petRepositoryHash() => r'dc436d013037701d473161c1265dd0537473740d';

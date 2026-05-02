// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton [MoodRepository].

@ProviderFor(moodRepository)
final moodRepositoryProvider = MoodRepositoryProvider._();

/// Provides the singleton [MoodRepository].

final class MoodRepositoryProvider
    extends $FunctionalProvider<MoodRepository, MoodRepository, MoodRepository>
    with $Provider<MoodRepository> {
  /// Provides the singleton [MoodRepository].
  MoodRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moodRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moodRepositoryHash();

  @$internal
  @override
  $ProviderElement<MoodRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MoodRepository create(Ref ref) {
    return moodRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoodRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoodRepository>(value),
    );
  }
}

String _$moodRepositoryHash() => r'd629675517b629782f772f55d0799f8b2582d6ad';

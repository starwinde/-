// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_seed_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(devSeedService)
final devSeedServiceProvider = DevSeedServiceProvider._();

final class DevSeedServiceProvider
    extends $FunctionalProvider<DevSeedService, DevSeedService, DevSeedService>
    with $Provider<DevSeedService> {
  DevSeedServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devSeedServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devSeedServiceHash();

  @$internal
  @override
  $ProviderElement<DevSeedService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DevSeedService create(Ref ref) {
    return devSeedService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevSeedService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevSeedService>(value),
    );
  }
}

String _$devSeedServiceHash() => r'aa9f7326b264915c3d287e8800f5ea5f924aa524';

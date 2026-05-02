// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_sync_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a keepAlive [OutboxSyncEngine] singleton.

@ProviderFor(outboxSyncEngine)
final outboxSyncEngineProvider = OutboxSyncEngineProvider._();

/// Provides a keepAlive [OutboxSyncEngine] singleton.

final class OutboxSyncEngineProvider
    extends
        $FunctionalProvider<
          OutboxSyncEngine,
          OutboxSyncEngine,
          OutboxSyncEngine
        >
    with $Provider<OutboxSyncEngine> {
  /// Provides a keepAlive [OutboxSyncEngine] singleton.
  OutboxSyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxSyncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxSyncEngineHash();

  @$internal
  @override
  $ProviderElement<OutboxSyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxSyncEngine create(Ref ref) {
    return outboxSyncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxSyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxSyncEngine>(value),
    );
  }
}

String _$outboxSyncEngineHash() => r'd0c4407c066707202c7e728c2007e91f48fc8920';

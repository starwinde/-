// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_log_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider.

@ProviderFor(usageLogRepository)
final usageLogRepositoryProvider = UsageLogRepositoryProvider._();

/// Riverpod provider.

final class UsageLogRepositoryProvider
    extends
        $FunctionalProvider<
          UsageLogRepository,
          UsageLogRepository,
          UsageLogRepository
        >
    with $Provider<UsageLogRepository> {
  /// Riverpod provider.
  UsageLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usageLogRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usageLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<UsageLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UsageLogRepository create(Ref ref) {
    return usageLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsageLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsageLogRepository>(value),
    );
  }
}

String _$usageLogRepositoryHash() =>
    r'db87d43e57ffae9615e8b4f704dcd283bfe1df03';

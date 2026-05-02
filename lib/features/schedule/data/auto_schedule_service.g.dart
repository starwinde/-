// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_schedule_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [AutoScheduleService] wired to the global [ApiClient].

@ProviderFor(autoScheduleService)
final autoScheduleServiceProvider = AutoScheduleServiceProvider._();

/// Provides [AutoScheduleService] wired to the global [ApiClient].

final class AutoScheduleServiceProvider
    extends
        $FunctionalProvider<
          AutoScheduleService,
          AutoScheduleService,
          AutoScheduleService
        >
    with $Provider<AutoScheduleService> {
  /// Provides [AutoScheduleService] wired to the global [ApiClient].
  AutoScheduleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoScheduleServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoScheduleServiceHash();

  @$internal
  @override
  $ProviderElement<AutoScheduleService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoScheduleService create(Ref ref) {
    return autoScheduleService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoScheduleService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoScheduleService>(value),
    );
  }
}

String _$autoScheduleServiceHash() =>
    r'4918a8334f47038a000ddfd174357bab7aa4e4e4';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the onboarding completion flag from SharedPreferences.
/// (rules.md 3.5: SharedPreferences for UI settings only — onboarding
/// completion qualifies as UI setting.)

@ProviderFor(onboardingComplete)
final onboardingCompleteProvider = OnboardingCompleteProvider._();

/// Provides the onboarding completion flag from SharedPreferences.
/// (rules.md 3.5: SharedPreferences for UI settings only — onboarding
/// completion qualifies as UI setting.)

final class OnboardingCompleteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provides the onboarding completion flag from SharedPreferences.
  /// (rules.md 3.5: SharedPreferences for UI settings only — onboarding
  /// completion qualifies as UI setting.)
  OnboardingCompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingCompleteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompleteHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return onboardingComplete(ref);
  }
}

String _$onboardingCompleteHash() =>
    r'745ff7ea6156e57e1aefd945fbef451cb6775994';

/// GoRouter configuration with auth + onboarding redirect logic.
/// keepAlive prevents GoRouter from being recreated on provider rebuild.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// GoRouter configuration with auth + onboarding redirect logic.
/// keepAlive prevents GoRouter from being recreated on provider rebuild.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// GoRouter configuration with auth + onboarding redirect logic.
  /// keepAlive prevents GoRouter from being recreated on provider rebuild.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'd1d272f67170cac966e10cf54e17231809e6bb6d';

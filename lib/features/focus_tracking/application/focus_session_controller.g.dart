// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Foreground polling controller for focus sessions.
///
/// - App foreground: Dart Timer.periodic 60s polls UsageApi.
/// - App background: FocusForegroundService.kt polls and caches to
///   SharedPreferences.
/// - On re-entry: [mergeCachedUsage] reads the background cache and
///   returns it for Drift insertion.

@ProviderFor(FocusSessionController)
final focusSessionControllerProvider = FocusSessionControllerProvider._();

/// Foreground polling controller for focus sessions.
///
/// - App foreground: Dart Timer.periodic 60s polls UsageApi.
/// - App background: FocusForegroundService.kt polls and caches to
///   SharedPreferences.
/// - On re-entry: [mergeCachedUsage] reads the background cache and
///   returns it for Drift insertion.
final class FocusSessionControllerProvider
    extends $NotifierProvider<FocusSessionController, bool> {
  /// Foreground polling controller for focus sessions.
  ///
  /// - App foreground: Dart Timer.periodic 60s polls UsageApi.
  /// - App background: FocusForegroundService.kt polls and caches to
  ///   SharedPreferences.
  /// - On re-entry: [mergeCachedUsage] reads the background cache and
  ///   returns it for Drift insertion.
  FocusSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusSessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusSessionControllerHash();

  @$internal
  @override
  FocusSessionController create() => FocusSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$focusSessionControllerHash() =>
    r'9bb23aef09bff5c1fed93b4d5aaa32a8832ece72';

/// Foreground polling controller for focus sessions.
///
/// - App foreground: Dart Timer.periodic 60s polls UsageApi.
/// - App background: FocusForegroundService.kt polls and caches to
///   SharedPreferences.
/// - On re-entry: [mergeCachedUsage] reads the background cache and
///   returns it for Drift insertion.

abstract class _$FocusSessionController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

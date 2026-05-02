// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persisted app theme mode (system / light / dark).
///
/// rules.md §3.5 허용: SharedPreferences는 UI 설정 전용 — ThemeMode 해당.

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// Persisted app theme mode (system / light / dark).
///
/// rules.md §3.5 허용: SharedPreferences는 UI 설정 전용 — ThemeMode 해당.
final class ThemeModeNotifierProvider
    extends $AsyncNotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// Persisted app theme mode (system / light / dark).
  ///
  /// rules.md §3.5 허용: SharedPreferences는 UI 설정 전용 — ThemeMode 해당.
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();
}

String _$themeModeNotifierHash() => r'bea84a6f08a8468a78609bc19af8f7ce70d2de10';

/// Persisted app theme mode (system / light / dark).
///
/// rules.md §3.5 허용: SharedPreferences는 UI 설정 전용 — ThemeMode 해당.

abstract class _$ThemeModeNotifier extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

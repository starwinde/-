// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wizard_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Multi-turn refinement 세션. wizard preview 단위로 auto-dispose.
/// 5턴 상한 + 마지막 2턴 윈도잉 (ADR 0003).

@ProviderFor(RefinementSessionNotifier)
final refinementSessionProvider = RefinementSessionNotifierProvider._();

/// Multi-turn refinement 세션. wizard preview 단위로 auto-dispose.
/// 5턴 상한 + 마지막 2턴 윈도잉 (ADR 0003).
final class RefinementSessionNotifierProvider
    extends $NotifierProvider<RefinementSessionNotifier, RefinementSession?> {
  /// Multi-turn refinement 세션. wizard preview 단위로 auto-dispose.
  /// 5턴 상한 + 마지막 2턴 윈도잉 (ADR 0003).
  RefinementSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refinementSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refinementSessionNotifierHash();

  @$internal
  @override
  RefinementSessionNotifier create() => RefinementSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefinementSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefinementSession?>(value),
    );
  }
}

String _$refinementSessionNotifierHash() =>
    r'984065e9ce772564ae316a4a0b16e4620afdca13';

/// Multi-turn refinement 세션. wizard preview 단위로 auto-dispose.
/// 5턴 상한 + 마지막 2턴 윈도잉 (ADR 0003).

abstract class _$RefinementSessionNotifier
    extends $Notifier<RefinementSession?> {
  RefinementSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RefinementSession?, RefinementSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RefinementSession?, RefinementSession?>,
              RefinementSession?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Holds the in-progress answers for the weekly wizard.
///
/// keepAlive: state must survive page navigation. The new role-based wizard
/// (RoleWizardPage) sets answers then unmounts before [WizardPreviewPage]
/// mounts and reads them — without keepAlive, auto-dispose wipes state
/// between the two pages.

@ProviderFor(WizardState)
final wizardStateProvider = WizardStateProvider._();

/// Holds the in-progress answers for the weekly wizard.
///
/// keepAlive: state must survive page navigation. The new role-based wizard
/// (RoleWizardPage) sets answers then unmounts before [WizardPreviewPage]
/// mounts and reads them — without keepAlive, auto-dispose wipes state
/// between the two pages.
final class WizardStateProvider
    extends $NotifierProvider<WizardState, WizardDraft> {
  /// Holds the in-progress answers for the weekly wizard.
  ///
  /// keepAlive: state must survive page navigation. The new role-based wizard
  /// (RoleWizardPage) sets answers then unmounts before [WizardPreviewPage]
  /// mounts and reads them — without keepAlive, auto-dispose wipes state
  /// between the two pages.
  WizardStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wizardStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wizardStateHash();

  @$internal
  @override
  WizardState create() => WizardState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WizardDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WizardDraft>(value),
    );
  }
}

String _$wizardStateHash() => r'7c0f1abffaabcb99f71c080bee9d023d7c94f73c';

/// Holds the in-progress answers for the weekly wizard.
///
/// keepAlive: state must survive page navigation. The new role-based wizard
/// (RoleWizardPage) sets answers then unmounts before [WizardPreviewPage]
/// mounts and reads them — without keepAlive, auto-dispose wipes state
/// between the two pages.

abstract class _$WizardState extends $Notifier<WizardDraft> {
  WizardDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WizardDraft, WizardDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WizardDraft, WizardDraft>,
              WizardDraft,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

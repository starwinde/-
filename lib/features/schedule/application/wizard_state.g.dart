// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wizard_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the in-progress answers for the weekly wizard.

@ProviderFor(WizardState)
final wizardStateProvider = WizardStateProvider._();

/// Holds the in-progress answers for the weekly wizard.
final class WizardStateProvider
    extends $NotifierProvider<WizardState, WizardDraft> {
  /// Holds the in-progress answers for the weekly wizard.
  WizardStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wizardStateProvider',
        isAutoDispose: true,
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

String _$wizardStateHash() => r'3dc2ff4c1fb1c12bcca318cbda4853c941c2e24c';

/// Holds the in-progress answers for the weekly wizard.

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

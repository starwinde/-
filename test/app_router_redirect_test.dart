import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/app.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/auth/data/auth_repository.dart';
import 'package:routinemon/features/auth/domain/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._user);
  final AuthUser? _user;

  @override
  AuthUser? getCurrentUser() => _user;

  @override
  Future<AuthUser> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  String? get accessToken => null;
}

ProviderContainer _container({
  required bool onboardingDone,
  AuthUser? user,
}) {
  SharedPreferences.setMockInitialValues({
    if (onboardingDone) 'onboarding_complete': true,
  });
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
    ],
  );
}

void main() {
  group('rev 27 redirect logic', () {
    testWidgets('guest + onboarding done -> /home stays at /home',
        (tester) async {
      final c = _container(onboardingDone: true);
      addTearDown(c.dispose);
      final router = c.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets('guest + onboarding NOT done -> stays at /onboarding',
        (tester) async {
      final c = _container(onboardingDone: false);
      addTearDown(c.dispose);
      final router = c.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          router.routerDelegate.currentConfiguration.uri.path, '/onboarding');
    });

    testWidgets(
        'simulate _goHome flow: prefs flip + invalidate + go(/home) from /egg-hatch',
        (tester) async {
      final c = _container(onboardingDone: false);
      addTearDown(c.dispose);
      final router = c.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/egg-hatch');
      await tester.pumpAndSettle();
      expect(
          router.routerDelegate.currentConfiguration.uri.path, '/egg-hatch');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      c.invalidate(onboardingCompleteProvider);
      router.go('/home');

      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home',
          reason: 'After completing egg-hatch, 시작하기 should land on /home.');
    });

    testWidgets(
        'EDGE CASE: pref already true (set in _completeOnboarding) but provider stale false',
        (tester) async {
      // This simulates the case where _completeOnboarding (onboarding_page.dart line 56)
      // sets pref=true BUT does NOT invalidate the provider. The cached provider value is
      // false. Then user goes through /egg-hatch and presses 시작하기.
      final c = _container(onboardingDone: false);
      addTearDown(c.dispose);
      final router = c.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Provider has resolved to AsyncData(false) at this point.
      // Now simulate _completeOnboarding setting pref=true but NOT invalidating:
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      // NO invalidate here — this is the critical detail.

      router.go('/egg-hatch');
      await tester.pumpAndSettle();

      // Now from egg-hatch, _goHome runs (DOES invalidate):
      c.invalidate(onboardingCompleteProvider);
      router.go('/home');
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home',
          reason:
              '_goHome invalidates so this should still work despite '
              'the earlier _completeOnboarding race.');
    });

    testWidgets(
        'CRITICAL: what if redirect runs BEFORE invalidate completes (race timing)',
        (tester) async {
      // Simulate the precise race the user reports:
      // _goHome -> setBool -> invalidate -> go(/home)
      // If redirect runs and sees AsyncData(false) (NOT AsyncLoading), it would
      // bounce to /onboarding. We expect AsyncLoading after invalidate, but verify.
      final c = _container(onboardingDone: false);
      addTearDown(c.dispose);
      final router = c.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/egg-hatch');
      await tester.pumpAndSettle();

      // Read provider state RIGHT after invalidate, no async gap.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      c.invalidate(onboardingCompleteProvider);

      // CHECK: what does ref.read return immediately after invalidate?
      final stateAfterInvalidate = c.read(onboardingCompleteProvider);
      // Print so we can see in test log
      // ignore: avoid_print
      print('[probe] state after invalidate: $stateAfterInvalidate');
      // ignore: avoid_print
      print('[probe] isLoading: ${stateAfterInvalidate.isLoading}');
      // ignore: avoid_print
      print('[probe] hasValue: ${stateAfterInvalidate.hasValue}');
      // ignore: avoid_print
      print('[probe] value: ${stateAfterInvalidate.value}');

      router.go('/home');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });
  });
}

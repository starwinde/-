import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/sync/outbox_sync_engine.dart';
import 'package:routinemon/core/theme/app_theme.dart';
import 'package:routinemon/core/theme/theme_mode_provider.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';
import 'package:routinemon/features/ai/presentation/ai_report_page.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/auth/presentation/login_page.dart';
import 'package:routinemon/features/data_export/presentation/data_export_page.dart';
import 'package:routinemon/features/disturbance/application/disturbance_controller.dart';
import 'package:routinemon/features/disturbance/presentation/usage_history_page.dart';
import 'package:routinemon/features/disturbance/presentation/usage_log_tile.dart';
import 'package:routinemon/features/mood/presentation/mood_check_in_tile.dart';
import 'package:routinemon/features/mood/presentation/mood_history_page.dart';
import 'package:routinemon/features/onboarding/presentation/egg_hatch_page.dart';
import 'package:routinemon/features/onboarding/presentation/onboarding_page.dart';
import 'package:routinemon/features/onboarding/presentation/permission_page.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:routinemon/features/pet/presentation/pet_card.dart';
import 'package:routinemon/features/pet/presentation/pet_detail_page.dart';
import 'package:routinemon/features/schedule/presentation/schedule_create_page.dart';
import 'package:routinemon/features/schedule/presentation/schedule_page.dart';
import 'package:routinemon/features/schedule/presentation/trash_page.dart';
import 'package:routinemon/features/schedule/presentation/wizard_page.dart';
import 'package:routinemon/features/schedule/presentation/wizard_preview_page.dart';
import 'package:routinemon/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app.g.dart';

/// Provides the onboarding completion flag from SharedPreferences.
/// (rules.md 3.5: SharedPreferences for UI settings only — onboarding
/// completion qualifies as UI setting.)
@riverpod
Future<bool> onboardingComplete(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
}

/// Listenable that notifies GoRouter when auth or onboarding state changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final _refreshNotifier = _RouterRefreshNotifier();

/// Root navigator key shared with GoRouter. Used by [DisturbanceController]
/// to display overlays on app resume without holding a stale BuildContext.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration with auth + onboarding redirect logic.
/// keepAlive prevents GoRouter from being recreated on provider rebuild.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Listen for auth/onboarding changes and trigger redirect re-evaluation
  // without recreating the GoRouter instance.
  ref.listen(authProvider, (_, __) => _refreshNotifier.notify());
  ref.listen(onboardingCompleteProvider, (_, __) => _refreshNotifier.notify());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/onboarding',
    refreshListenable: _refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final onboardingState = ref.read(onboardingCompleteProvider);

      // While loading, don't redirect — stay on current page.
      if (authState.isLoading || onboardingState.isLoading) return null;

      final isOnboardingDone = onboardingState.value ?? false;
      final location = state.matchedLocation;

      // Allow egg-hatch to proceed without redirect
      if (location == '/egg-hatch') return null;

      // PRD §2.13 (rev 27, 2026-05-04): 게스트 모드 허용. Onboarding 완료 여부가
      // 라우팅 권한의 단일 기준. 인증은 동기화 활성화의 부가 기능.
      if (!isOnboardingDone && location != '/onboarding') {
        return '/onboarding';
      }

      if (isOnboardingDone &&
          (location == '/onboarding' || location == '/login')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/permission',
        builder: (context, state) => const PermissionPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const _HomePage(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const SchedulePage(),
      ),
      GoRoute(
        path: '/schedule/create',
        builder: (context, state) => const ScheduleCreatePage(),
      ),
      GoRoute(
        path: '/schedule/edit/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return ScheduleCreatePage(scheduleId: id);
        },
      ),
      GoRoute(
        path: '/schedule/wizard',
        builder: (context, state) => const WizardPage(),
      ),
      GoRoute(
        path: '/schedule/wizard/preview',
        builder: (context, state) => const WizardPreviewPage(),
      ),
      GoRoute(
        path: '/trash',
        builder: (context, state) => const TrashPage(),
      ),
      GoRoute(
        path: '/egg-hatch',
        builder: (context, state) {
          final species = state.extra as PetSpecies? ?? PetSpecies.bird;
          return EggHatchPage(species: species);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/export',
        builder: (context, state) => const DataExportPage(),
      ),
      GoRoute(
        path: '/mood/history',
        builder: (context, state) => const MoodHistoryPage(),
      ),
      GoRoute(
        path: '/usage/history',
        builder: (context, state) => const UsageHistoryPage(),
      ),
      GoRoute(
        path: '/pet/detail',
        builder: (context, state) => const PetDetailPage(),
      ),
      GoRoute(
        path: '/ai/report',
        builder: (context, state) {
          final period = state.extra as ReportPeriod? ?? ReportPeriod.weekly;
          return AiReportPage(period: period);
        },
      ),
    ],
  );
}

/// Root widget of the routinemon application. Wires the GoRouter with a
/// MaterialApp.router and installs the pastel-green seed theme.
class RoutinemonApp extends ConsumerWidget {
  /// Creates the root application widget.
  const RoutinemonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    // Start outbox sync engine (5min interval, PRD 2.12).
    ref.read(outboxSyncEngineProvider).start();

    // Start disturbance controller (T5.21 일정별 방해 허용).
    ref.read(disturbanceControllerProvider).start();

    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    return MaterialApp.router(
      title: '루틴몬',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴몬'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '설정',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('홈 대시보드', style: TextStyle(fontSize: 20)),
          ),
          PetCard(),
          MoodCheckInTile(),
          UsageLogTile(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: '일정',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets),
            label: '펫',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              unawaited(context.push('/schedule'));
            case 2:
              unawaited(context.push('/pet/detail'));
          }
        },
      ),
    );
  }
}

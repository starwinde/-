import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/onboarding/presentation/permission_page.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 5-step onboarding flow (PRD 2.3, T2.8).
///
/// Steps:
/// 1. Introduction (app overview)
/// 2. Login (delegated to /login route)
/// 3. Permission (reuses PermissionPage widget)
/// 4. Focus time selection
/// 5. Egg selection (bird/dragon/dolphin)
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  TimeOfDay _focusStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _focusEnd = const TimeOfDay(hour: 18, minute: 0);
  PetSpecies? _selectedSpecies;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      unawaited(
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedSpecies == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      context.go(
        '/egg-hatch',
        extra: _selectedSpecies,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= _currentStep
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) =>
                    setState(() => _currentStep = index),
                children: [
                  _IntroStep(onNext: _nextStep),
                  _LoginStep(onNext: _nextStep),
                  _PermissionStep(onNext: _nextStep),
                  _FocusTimeStep(
                    focusStart: _focusStart,
                    focusEnd: _focusEnd,
                    onStartChanged: (t) =>
                        setState(() => _focusStart = t),
                    onEndChanged: (t) => setState(() => _focusEnd = t),
                    onNext: _nextStep,
                  ),
                  _EggSelectionStep(
                    selected: _selectedSpecies,
                    onSelected: (s) =>
                        setState(() => _selectedSpecies = s),
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Step 1: Introduction ---
class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '루틴몬에 오신 것을 환영합니다!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '집중 시간 동안 폰을 내려놓으면\n'
            'XP를 얻어 나만의 펫을 키울 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onNext,
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }
}

// --- Step 2: Login ---
class _LoginStep extends ConsumerStatefulWidget {
  const _LoginStep({required this.onNext});
  final VoidCallback onNext;

  @override
  ConsumerState<_LoginStep> createState() => _LoginStepState();
}

class _LoginStepState extends ConsumerState<_LoginStep> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final googleUser = await GoogleSignIn(
        serverClientId:
            '727331473868-4q2cvt9fs0r9l2gbdr08bo3iuk82ki4b.apps.googleusercontent.com',
      ).signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        setState(() {
          _error = 'Google 로그인에서 ID 토큰을 받지 못했습니다.';
          _loading = false;
        });
        return;
      }

      await ref.read(authProvider.notifier).signInWithGoogle(
            idToken: idToken,
            accessToken: googleAuth.accessToken,
          );

      if (mounted) {
        widget.onNext();
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = '로그인 실패: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.login, size: 64),
          const SizedBox(height: 24),
          Text(
            '로그인',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'Google 계정으로 로그인하세요.\n'
            '데이터가 안전하게 동기화됩니다.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed: _loading ? null : _signInWithGoogle,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.account_circle),
            label: Text(_loading ? '로그인 중...' : 'Google로 로그인'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : widget.onNext,
            child: const Text('나중에 로그인'),
          ),
        ],
      ),
    );
  }
}

// --- Step 3: Permission ---
class _PermissionStep extends StatelessWidget {
  const _PermissionStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PermissionPage(onComplete: onNext),
        ),
      ],
    );
  }
}

// --- Step 4: Focus Time ---
class _FocusTimeStep extends StatelessWidget {
  const _FocusTimeStep({
    required this.focusStart,
    required this.focusEnd,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onNext,
  });

  final TimeOfDay focusStart;
  final TimeOfDay focusEnd;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 64),
          const SizedBox(height: 24),
          Text(
            '집중 시간대 설정',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text(
            '이 시간 동안 폰을 내려놓으면\nXP를 얻을 수 있어요.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text('시작: ${focusStart.format(context)}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: focusStart,
              );
              if (t != null) onStartChanged(t);
            },
          ),
          ListTile(
            title: Text('종료: ${focusEnd.format(context)}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: focusEnd,
              );
              if (t != null) onEndChanged(t);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onNext,
            child: const Text('다음'),
          ),
        ],
      ),
    );
  }
}

// --- Step 5: Egg Selection ---
class _EggSelectionStep extends StatelessWidget {
  const _EggSelectionStep({
    required this.selected,
    required this.onSelected,
    required this.onComplete,
  });

  final PetSpecies? selected;
  final ValueChanged<PetSpecies> onSelected;
  final VoidCallback onComplete;

  static const _speciesInfo = {
    PetSpecies.bird: (
      label: '새',
      description: '빠르게 성장하는 신화의 새',
      icon: Icons.flutter_dash,
    ),
    PetSpecies.dragon: (
      label: '드래곤',
      description: '웅장한 판타지 드래곤',
      icon: Icons.local_fire_department,
    ),
    PetSpecies.dolphin: (
      label: '돌고래',
      description: '신성한 바다의 왕',
      icon: Icons.water,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '알을 선택하세요',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            '어떤 펫을 키울지 결정해 보세요!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...PetSpecies.values.map((species) {
            final info = _speciesInfo[species]!;
            final isSelected = selected == species;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                    : null,
                child: ListTile(
                  leading: Icon(
                    info.icon,
                    size: 40,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(info.label),
                  subtitle: Text(info.description),
                  selected: isSelected,
                  onTap: () => onSelected(species),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: selected != null ? onComplete : null,
            child: const Text('알 부화 시작!'),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routinemon/app.dart';
import 'package:routinemon/core/db/app_database.dart' as db;
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:routinemon/features/pet/domain/pet_name_validator.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 5-stage egg hatching animation (T2.10).
///
/// Stages: egg -> gold dust -> cracking -> pet appears -> name input.
/// Uses AnimatedSwitcher with placeholder colored boxes (no assets in Phase 2).
class EggHatchPage extends ConsumerStatefulWidget {
  const EggHatchPage({super.key, required this.species});

  final PetSpecies species;

  @override
  ConsumerState<EggHatchPage> createState() => _EggHatchPageState();
}

class _EggHatchPageState extends ConsumerState<EggHatchPage> {
  int _stage = 0; // 0..4
  final _nameController = TextEditingController();
  String? _nameError;
  bool _saving = false;
  String? _welcomeMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _advanceStage() {
    if (_stage < 3) {
      setState(() => _stage++);
    }
  }

  Future<void> _submitName() async {
    final name = _nameController.text.trim();
    if (!PetNameValidator.isValid(name)) {
      setState(() => _nameError = '1~10자, 금지어 제외');
      return;
    }

    setState(() {
      _nameError = null;
      _saving = true;
    });

    final userId = ref.read(authProvider).value?.id ?? 'local';
    final database = ref.read(appDatabaseProvider);

    // Insert pet into Drift + outbox (rules.md 3.7)
    await database.transaction(() async {
      final petId = await database.into(database.pets).insert(
            db.PetsCompanion.insert(
              userId: userId,
              species: widget.species.name,
              name: name,
            ),
          );
      await database.into(database.outbox).insert(
            db.OutboxCompanion.insert(
              targetTable: 'pets',
              rowId: petId.toString(),
              operation: 'insert',
              payload: '{}',
            ),
          );
    });

    // Fetch welcome greeting from n8n /webhook/routinemon/ai/welcome
    String greeting;
    try {
      final response = await ref.read(apiClientProvider).post(
            '/webhook/routinemon/ai/welcome',
            body: {'locale': 'ko', 'petName': name},
          );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      greeting = (data['greeting'] as String?) ??
          '반가워, $name! 우리 함께 멋진 하루를 만들어보자.';
    } on Exception catch (_) {
      greeting = '반가워, $name! 우리 함께 멋진 하루를 만들어보자.';
    }

    if (mounted) {
      setState(() {
        _stage = 4;
        _saving = false;
        _welcomeMessage = greeting;
      });
    }
  }

  Future<void> _goHome() async {
    // Mark onboarding as complete so GoRouter redirect allows /home.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    // Invalidate the cached provider so redirect picks up the new value.
    ref.invalidate(onboardingCompleteProvider);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildStage(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildStage(ThemeData theme) {
    return switch (_stage) {
      0 => _EggStage(
          key: const ValueKey(0),
          species: widget.species,
          onTap: _advanceStage,
        ),
      1 => _GoldDustStage(
          key: const ValueKey(1),
          onTap: _advanceStage,
        ),
      2 => _CrackingStage(
          key: const ValueKey(2),
          onTap: _advanceStage,
        ),
      3 => _NameInputStage(
          key: const ValueKey(3),
          species: widget.species,
          controller: _nameController,
          error: _nameError,
          saving: _saving,
          onSubmit: _submitName,
        ),
      4 => _WelcomeStage(
          key: const ValueKey(4),
          species: widget.species,
          name: _nameController.text.trim(),
          message: _welcomeMessage ?? '',
          onContinue: _goHome,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// --- Stage 0: Egg ---
class _EggStage extends StatelessWidget {
  const _EggStage({super.key, required this.species, required this.onTap});
  final PetSpecies species;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              color: _eggColor(species),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '알을 터치하세요!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Color _eggColor(PetSpecies species) {
    return switch (species) {
      PetSpecies.bird => const Color(0xFFFFD54F),
      PetSpecies.dragon => const Color(0xFFEF5350),
      PetSpecies.dolphin => const Color(0xFF42A5F5),
    };
  }
}

// --- Stage 1: Gold Dust ---
class _GoldDustStage extends StatelessWidget {
  const _GoldDustStage({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.shade200,
                  Colors.amber.shade600,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '금빛 가루가 흩날리고 있어요...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

// --- Stage 2: Cracking ---
class _CrackingStage extends StatelessWidget {
  const _CrackingStage({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.amber.shade300,
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
              const Icon(Icons.flash_on, size: 60, color: Colors.white),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '알이 갈라지고 있어요!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

// --- Stage 3: Name Input ---
class _NameInputStage extends StatelessWidget {
  const _NameInputStage({
    super.key,
    required this.species,
    required this.controller,
    required this.error,
    required this.saving,
    required this.onSubmit,
  });

  final PetSpecies species;
  final TextEditingController controller;
  final String? error;
  final bool saving;
  final VoidCallback onSubmit;

  static const _speciesLabels = {
    PetSpecies.bird: '아기새',
    PetSpecies.dragon: '새끼 드래곤',
    PetSpecies.dolphin: '아기 돌고래',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.egg_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '${_speciesLabels[species]}가 태어났어요!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '이름을 지어주세요',
              border: const OutlineInputBorder(),
              errorText: error,
            ),
            maxLength: 10,
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: saving ? null : onSubmit,
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('이름 짓기'),
          ),
        ],
      ),
    );
  }
}

// --- Stage 4: Welcome ---
class _WelcomeStage extends StatelessWidget {
  const _WelcomeStage({
    super.key,
    required this.species,
    required this.name,
    required this.message,
    required this.onContinue,
  });

  final PetSpecies species;
  final String name;
  final String message;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onContinue,
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }
}

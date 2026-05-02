import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:routinemon/features/auth/application/auth_notifier.dart';

/// Login page shown as the first screen. Google sign-in is the only method.
class LoginPage extends ConsumerStatefulWidget {
  /// Creates the login page.
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
        // User cancelled the sign-in flow.
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
        context.go('/permission');
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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '루틴몬',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '집중하면 성장하는 나만의 펫',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _signInWithGoogle,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_loading ? '로그인 중...' : 'Google로 시작하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

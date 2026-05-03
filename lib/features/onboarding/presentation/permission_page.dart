import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routinemon/core/native/usage_bridge.dart';

/// UsageStats 특수 권한을 요청하는 온보딩 페이지.
///
/// When [onComplete] is provided, it is called instead of navigating to '/'.
/// This allows embedding in the onboarding flow (Step 3) or standalone use.
class PermissionPage extends ConsumerStatefulWidget {
  /// Creates the permission request page.
  const PermissionPage({super.key, this.onComplete});

  /// Optional callback invoked when permission is granted.
  /// If null, navigates to '/' via GoRouter.
  final VoidCallback? onComplete;

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage>
    with WidgetsBindingObserver {
  bool _autoProgressed = false; // 자동 onComplete 단발성 가드

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // OS 설정에서 권한 부여하고 돌아왔을 때 캐시 무효화 → build 가 새 값으로 재평가.
      ref.invalidate(hasUsagePermissionProvider);
    }
  }

  Future<void> _openSettings() async {
    final api = ref.read(usageApiProvider);
    await api.openUsageSettings();
  }

  void _scheduleAutoProgressIfNeeded() {
    if (_autoProgressed) return;
    _autoProgressed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(hasUsagePermissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('권한 설정')),
      body: Center(
        child: permissionAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (_, _) => const Text('권한 확인 중 오류가 발생했습니다.'),
          data: (hasPermission) {
            if (hasPermission) {
              _scheduleAutoProgressIfNeeded();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('권한이 허용되었습니다!'),
                  const SizedBox(height: 16),
                  // 자동 진행 실패 시 fallback 으로 사용자가 직접 누를 수 있는 버튼.
                  FilledButton(
                    onPressed: () {
                      if (widget.onComplete != null) {
                        widget.onComplete!();
                      } else {
                        context.go('/');
                      }
                    },
                    child: const Text('다음'),
                  ),
                ],
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '루틴몬이 집중 시간을 측정하려면\n'
                    '사용 정보 접근 권한이 필요합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _openSettings,
                  child: const Text('설정으로 이동'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

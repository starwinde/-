import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routinemon/features/focus_tracking/domain/blacklist_intervention.dart';

/// [InterventionLevel]에 따른 개입 UI를 표시하는 유틸리티.
///
/// - [InterventionLevel.notification]: SnackBar
/// - [InterventionLevel.popup]: AlertDialog
/// - [InterventionLevel.fullscreen]: 전체 화면 경고 Scaffold
/// - [InterventionLevel.none]: 아무것도 하지 않음
class InterventionOverlay {
  const InterventionOverlay._();

  /// 주어진 [level]에 맞는 개입 UI를 표시한다.
  static void show(BuildContext context, InterventionLevel level) {
    switch (level) {
      case InterventionLevel.none:
        break;
      case InterventionLevel.notification:
        _showNotification(context);
      case InterventionLevel.popup:
        _showPopup(context);
      case InterventionLevel.fullscreen:
        _showFullscreen(context);
    }
  }

  static void _showNotification(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('집중 시간이에요! 블랙리스트 앱 사용을 줄여보세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void _showPopup(BuildContext context) {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48),
        title: const Text('블랙리스트 앱 반복 사용'),
        content: const Text(
          '집중 시간 중 블랙리스트 앱을 여러 번 열었어요.\n'
          '펫의 HP가 줄어들 수 있어요!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('알겠어요'),
          ),
        ],
      ),
    ));
  }

  static void _showFullscreen(BuildContext context) {
    unawaited(Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => const _FullscreenWarningPage(),
      ),
    ));
  }
}

class _FullscreenWarningPage extends StatelessWidget {
  const _FullscreenWarningPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 96,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 24),
                Text(
                  '집중 시간입니다!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '블랙리스트 앱을 5회 이상 열었어요.\n'
                  '펫이 많이 힘들어하고 있어요.\n'
                  '다시 집중해볼까요?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

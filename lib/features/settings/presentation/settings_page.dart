import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routinemon/core/theme/theme_mode_provider.dart';
import 'package:routinemon/features/ai/data/ai_report_models.dart';

/// 설정 페이지. 현재는 다크모드 토글만 (Block B1, T5.16).
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeAsync = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: modeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (current) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '테마',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정 따르기'),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(themeModeProvider.notifier)
                      .setMode(v);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(themeModeProvider.notifier)
                      .setMode(v);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (v) async {
                if (v != null) {
                  await ref
                      .read(themeModeProvider.notifier)
                      .setMode(v);
                }
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '데이터',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('데이터 내보내기'),
              subtitle: const Text('일정·세션·펫을 JSON으로 복사'),
              onTap: () => context.push('/settings/export'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('주간 AI 리포트'),
              subtitle: const Text('로컬 LLM이 생성, PDF로 다운로드 가능'),
              onTap: () => context.push(
                '/ai/report',
                extra: ReportPeriod.weekly,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month),
              title: const Text('월간 AI 리포트'),
              subtitle: const Text('월간 요약 + PDF'),
              onTap: () => context.push(
                '/ai/report',
                extra: ReportPeriod.monthly,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

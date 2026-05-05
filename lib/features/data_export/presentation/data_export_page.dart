import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/data_export/data/data_export_service.dart';

/// T5.17 Data Export page. Copies the current user's Drift data to the
/// clipboard as JSON. Free tier allows 1 export per calendar month.
/// Pro unlimited enforcement is wired in once Block D-pay lands.
class DataExportPage extends ConsumerStatefulWidget {
  /// Creates the data-export screen.
  const DataExportPage({super.key});

  @override
  ConsumerState<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends ConsumerState<DataExportPage> {
  bool _busy = false;
  String? _lastResult;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final userId = ref.read(authProvider).value?.id ?? 'local';
      final service = ref.read(dataExportServiceProvider);
      // v1.0: 수익화 기능 이월(PRD §2.17 rev 18) — Pro quota 게이팅 비활성,
      // hasQuota/recordUsage 호출은 v1.1 수익화 도입 시 restore.
      final json = await service.exportAsJson(userId);
      await service.copyToClipboard(json);
      if (!mounted) return;
      setState(() {
        _lastResult = '${json.length} bytes 복사됨';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('JSON ${json.length} bytes 클립보드 복사 완료.')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('데이터 내보내기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '현재 계정의 일정·집중세션·펫·일일점수를 JSON으로 추출해 '
              '클립보드에 복사합니다. 이메일/메모 앱에 붙여넣어 백업하세요.',
            ),
            const SizedBox(height: 8),
            const Text(
              'v1.0: 무제한 사용. (v1.1 수익화 도입 시 정책 갱신 예정)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.copy),
              label: const Text('JSON을 클립보드로 복사'),
            ),
            if (_lastResult != null) ...[
              const SizedBox(height: 16),
              Text(
                '최근: $_lastResult',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

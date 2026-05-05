import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/core/native/usage_bridge.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/disturbance/data/usage_log_repository.dart';

/// 홈 대시보드 카드 — 오늘 누적 top-3 패키지 + 합계 분 (ADR 0004).
/// `MoodCheckInTile` 패턴.
class UsageLogTile extends ConsumerStatefulWidget {
  /// Creates the tile.
  const UsageLogTile({super.key});

  @override
  ConsumerState<UsageLogTile> createState() => _UsageLogTileState();
}

class _UsageLogTileState extends ConsumerState<UsageLogTile>
    with WidgetsBindingObserver {
  List<({String packageName, int totalMs})> _top = const [];
  Map<String, String> _labels = const {};
  int _totalMs = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // DisturbanceController 가 resumed 시점에 usage_logs 를 추가하므로
      // 짧게 대기 후 재로드해야 새 행이 잡힌다.
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          if (mounted) return _load();
          return null;
        }),
      );
    }
  }

  Future<void> _load() async {
    final userId = ref.read(authProvider).value?.id ?? 'local';
    final repo = ref.read(usageLogRepositoryProvider);
    final launcherSet = await ref.read(launcherPackagesProvider.future);
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final top = await repo.aggregateTopPackages(
      userId: userId,
      since: dayStart,
      excludePackages: launcherSet,
    );
    final total = await repo.totalMsSince(
      userId: userId,
      since: dayStart,
      excludePackages: launcherSet,
    );
    final labels = await ref
        .read(appLabelCacheProvider.notifier)
        .resolve(top.map((e) => e.packageName).toList());
    if (!mounted) return;
    setState(() {
      _top = top;
      _labels = labels;
      _totalMs = total;
      _loaded = true;
    });
  }

  String _formatDuration(int ms) {
    final totalSec = ms ~/ 1000;
    final m = totalSec ~/ 60;
    if (m == 0) return '${totalSec}초';
    if (m < 60) return '$m분';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '$h시간' : '$h시간 $rem분';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smartphone, size: 20),
                const SizedBox(width: 8),
                const Text('오늘 사용 기록', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  'Σ ${_formatDuration(_totalMs)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_top.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '아직 기록 없음',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ..._top.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _labels[e.packageName] ?? e.packageName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(_formatDuration(e.totalMs)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/usage/history'),
                child: const Text('자세히 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

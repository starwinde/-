import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/core/native/usage_bridge.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/disturbance/data/usage_log_repository.dart';

/// 사용 기록 이력 (오늘 / 7일 / 30일 토글) — ADR 0004.
class UsageHistoryPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const UsageHistoryPage({super.key});

  @override
  ConsumerState<UsageHistoryPage> createState() => _UsageHistoryPageState();
}

class _UsageHistoryPageState extends ConsumerState<UsageHistoryPage> {
  _Range _range = _Range.today;
  List<({String packageName, int totalMs})> _agg = const [];
  Map<int?, List<UsageLog>> _byScheduleId = const {};
  Map<String, String> _labels = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = ref.read(authProvider).value?.id ?? 'local';
    final repo = ref.read(usageLogRepositoryProvider);
    final launcherSet = await ref.read(launcherPackagesProvider.future);
    final now = DateTime.now();
    final since = switch (_range) {
      _Range.today => DateTime(now.year, now.month, now.day),
      _Range.week => now.subtract(const Duration(days: 7)),
      _Range.month => now.subtract(const Duration(days: 30)),
    };
    final agg = await repo.aggregateTopPackages(
      userId: userId,
      since: since,
      limit: 20,
      excludePackages: launcherSet,
    );
    // Schedule grouping fetched per-date, then flattened
    final all = <UsageLog>[];
    if (_range == _Range.today) {
      all.addAll(await repo.getForDate(userId, now));
    } else {
      final days = _range == _Range.week ? 7 : 30;
      for (var i = 0; i < days; i++) {
        all.addAll(await repo.getForDate(
          userId,
          now.subtract(Duration(days: i)),
        ));
      }
    }
    // launcher 패키지는 일정별 상세에서도 제외 — top-3 와 동일 정책 유지.
    all.removeWhere((r) => launcherSet.contains(r.packageName));
    final grouped = <int?, List<UsageLog>>{};
    for (final r in all) {
      grouped.putIfAbsent(r.scheduleId, () => []).add(r);
    }
    final allPackages = {
      ...agg.map((e) => e.packageName),
      ...all.map((e) => e.packageName),
    }.toList();
    final labels = await ref
        .read(appLabelCacheProvider.notifier)
        .resolve(allPackages);
    if (!mounted) return;
    setState(() {
      _agg = agg;
      _byScheduleId = grouped;
      _labels = labels;
      _loading = false;
    });
  }

  String _label(String packageName) => _labels[packageName] ?? packageName;

  String _formatDuration(int ms) {
    final m = ms ~/ 60000;
    if (m == 0) return '<1분';
    if (m < 60) return '$m분';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '$h시간' : '$h시간 $rem분';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용 기록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<_Range>(
              segments: const [
                ButtonSegment(value: _Range.today, label: Text('오늘')),
                ButtonSegment(value: _Range.week, label: Text('7일')),
                ButtonSegment(value: _Range.month, label: Text('30일')),
              ],
              selected: {_range},
              onSelectionChanged: (s) {
                setState(() => _range = s.first);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _agg.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            '기록이 없습니다.\n방해 허용이 켜진 일정에서 다른 앱 사용 후\n루틴몬으로 돌아오면 기록됩니다.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '패키지별 누적',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ..._agg.map(
                            (e) => ListTile(
                              dense: true,
                              title: Text(_label(e.packageName)),
                              subtitle: Text(
                                e.packageName,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: Text(_formatDuration(e.totalMs)),
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '일정별 그룹',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ..._byScheduleId.entries.map((e) {
                            final label = e.key == null
                                ? '일정 외 시간'
                                : '일정 #${e.key}';
                            final total = e.value.fold<int>(
                              0,
                              (a, r) => a + r.totalMs,
                            );
                            return ExpansionTile(
                              title: Text(label),
                              subtitle: Text(
                                '${e.value.length}건 · 누적 ${_formatDuration(total)}',
                              ),
                              children: e.value
                                  .map(
                                    (r) => ListTile(
                                      dense: true,
                                      title: Text(_label(r.packageName)),
                                      trailing:
                                          Text(_formatDuration(r.totalMs)),
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

enum _Range { today, week, month }

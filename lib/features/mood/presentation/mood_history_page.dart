import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/features/mood/data/mood_repository.dart';
import 'package:routinemon/features/mood/presentation/mood_check_in_dialog.dart';

/// History + line-chart view of mood entries.
class MoodHistoryPage extends ConsumerStatefulWidget {
  const MoodHistoryPage({super.key});

  @override
  ConsumerState<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

enum _Period { days7, days30, days90 }

class _MoodHistoryPageState extends ConsumerState<MoodHistoryPage> {
  _Period _period = _Period.days30;
  Map<String, List<MoodEntry>> _byDate = {};
  List<MoodEntry> _today = [];
  bool _loading = true;

  static const _emojis = ['😞', '😕', '😐', '🙂', '😄'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int _periodDays(_Period p) {
    switch (p) {
      case _Period.days7:
        return 7;
      case _Period.days30:
        return 30;
      case _Period.days90:
        return 90;
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(moodRepositoryProvider);
    final now = DateTime.now();
    final from = now.subtract(Duration(days: _periodDays(_period) - 1));
    final range = await repo.getMoodsInRange(from, now);
    final today = await repo.getMoodsForDate(now);
    if (!mounted) return;
    setState(() {
      _byDate = range;
      _today = today;
      _loading = false;
    });
  }

  Future<void> _addEntry() async {
    await showMoodCheckInDialog(context);
    await _load();
  }

  List<FlSpot> _buildSpots() {
    final now = DateTime.now();
    final days = _periodDays(_period);
    final spots = <FlSpot>[];
    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final key = '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      final list = _byDate[key];
      if (list != null && list.isNotEmpty) {
        final sum = list.fold<int>(0, (a, e) => a + e.mood);
        spots.add(FlSpot(i.toDouble(), sum / list.length));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    return Scaffold(
      appBar: AppBar(title: const Text('기분 기록')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SegmentedButton<_Period>(
                      segments: const [
                        ButtonSegment(value: _Period.days7, label: Text('7일')),
                        ButtonSegment(value: _Period.days30, label: Text('30일')),
                        ButtonSegment(value: _Period.days90, label: Text('90일')),
                      ],
                      selected: {_period},
                      onSelectionChanged: (sel) {
                        setState(() => _period = sel.first);
                        _load();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                      child: spots.isEmpty
                          ? const Center(
                              child: Text(
                                  '기록이 없습니다. 오른쪽 하단 + 버튼으로 추가하세요.'),
                            )
                          : LineChart(
                              LineChartData(
                                minY: 1,
                                maxY: 5,
                                gridData: const FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: 1,
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (v, meta) {
                                        final days = _periodDays(_period);
                                        final endIdx = days - 1;
                                        final labelIdxs = {
                                          0,
                                          endIdx ~/ 2,
                                          endIdx,
                                        };
                                        if (!labelIdxs.contains(v.toInt())) {
                                          return const SizedBox.shrink();
                                        }
                                        final date = DateTime.now().subtract(
                                            Duration(days: endIdx - v.toInt()));
                                        return Text(
                                          '${date.month}/${date.day}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    dotData: const FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      '오늘 (${_today.length}건)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (_today.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('오늘 기록 없음',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  for (final e in _today.reversed)
                    ListTile(
                      dense: true,
                      leading: Text(_emojis[e.mood - 1],
                          style: const TextStyle(fontSize: 24)),
                      title: Text(
                        '${e.timestamp.hour.toString().padLeft(2, '0')}:'
                        '${e.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: Text('${e.mood}/5',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                ],
              ),
            ),
    );
  }
}

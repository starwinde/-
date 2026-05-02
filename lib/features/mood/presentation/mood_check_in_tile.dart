import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/features/mood/data/mood_repository.dart';
import 'package:routinemon/features/mood/presentation/mood_check_in_dialog.dart';

/// Card widget shown on the home dashboard. Surfaces today's mood entries
/// (count + latest emoji) with quick "체크인" and "기록 보기" actions.
class MoodCheckInTile extends ConsumerStatefulWidget {
  /// Creates a mood check-in dashboard tile.
  const MoodCheckInTile({super.key});

  @override
  ConsumerState<MoodCheckInTile> createState() => _MoodCheckInTileState();
}

class _MoodCheckInTileState extends ConsumerState<MoodCheckInTile> {
  List<MoodEntry> _today = const [];
  bool _loaded = false;

  static const _emojis = ['😞', '😕', '😐', '🙂', '😄'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(moodRepositoryProvider);
    final entries = await repo.getMoodsForDate(DateTime.now());
    if (!mounted) return;
    setState(() {
      _today = entries;
      _loaded = true;
    });
  }

  Future<void> _prompt() async {
    await showMoodCheckInDialog(context);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final latestMood = _today.isEmpty ? null : _today.last.mood;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('오늘 기분', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                if (latestMood != null)
                  Text(_emojis[latestMood - 1],
                      style: const TextStyle(fontSize: 28))
                else
                  Text('미기록', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text('${_today.length}건',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _prompt,
                    icon: const Icon(Icons.mood),
                    label: const Text('체크인'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/mood/history'),
                    icon: const Icon(Icons.show_chart),
                    label: const Text('기록 보기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

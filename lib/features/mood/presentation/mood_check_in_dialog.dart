import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routinemon/features/mood/data/mood_repository.dart';

/// Opens the mood check-in dialog. When [initialDateTime] is provided the
/// dialog pre-selects that moment, allowing the user to record a mood for
/// a past point in time. Defaults to `DateTime.now()`.
Future<void> showMoodCheckInDialog(
  BuildContext context, {
  DateTime? initialDateTime,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => MoodCheckInDialog(initialDateTime: initialDateTime),
  );
}

/// Dialog letting the user record a mood (1..5) at a selectable timestamp.
///
/// The user can shift the date (up to 90 days back) and time to capture
/// entries they forgot on the day, then tap one of five emoji to commit.
class MoodCheckInDialog extends ConsumerStatefulWidget {
  /// Creates a mood check-in dialog. Pass [initialDateTime] to preset the
  /// timestamp (e.g. from a past-day entry point).
  const MoodCheckInDialog({super.key, this.initialDateTime});

  /// Initial timestamp; defaults to `DateTime.now()` when `null`.
  final DateTime? initialDateTime;

  @override
  ConsumerState<MoodCheckInDialog> createState() => _MoodCheckInDialogState();
}

class _MoodCheckInDialogState extends ConsumerState<MoodCheckInDialog> {
  late DateTime _dateTime;

  static const _emojis = ['😞', '😕', '😐', '🙂', '😄'];

  @override
  void initState() {
    super.initState();
    _dateTime = widget.initialDateTime ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dateTime.hour,
          _dateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _useNow() {
    setState(() => _dateTime = DateTime.now());
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('기분 기록'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_formatDate(_dateTime)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(_formatTime(_dateTime)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _useNow,
              child: const Text('지금'),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final value = index + 1;
              return Expanded(
                child: IconButton(
                  iconSize: 32,
                  icon:
                      Text(_emojis[index], style: const TextStyle(fontSize: 28)),
                  onPressed: () async {
                    await ref
                        .read(moodRepositoryProvider)
                        .addMoodEntry(_dateTime, value);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

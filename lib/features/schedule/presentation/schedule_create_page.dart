import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/core/native/disturbance_api.g.dart';
import 'package:routinemon/features/auth/application/auth_notifier.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

/// Schedule / to-do creation and edit form.
///
/// When [scheduleId] is non-null, the page operates in edit mode: it
/// prefills values from the existing row and calls
/// [ScheduleActions.updateSchedule] on submit. Otherwise it behaves as a
/// create form.
class ScheduleCreatePage extends ConsumerStatefulWidget {
  /// Creates the page in create mode, or in edit mode if [scheduleId] is set.
  const ScheduleCreatePage({super.key, this.scheduleId});

  /// If non-null, the page loads the existing schedule and submits an update.
  final int? scheduleId;

  /// True when the page is bound to an existing schedule row.
  bool get isEdit => scheduleId != null;

  @override
  ConsumerState<ScheduleCreatePage> createState() =>
      _ScheduleCreatePageState();
}

class _ScheduleCreatePageState extends ConsumerState<ScheduleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();

  ScheduleCategory _category = ScheduleCategory.etc;
  bool _isTodo = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _selectedDate;
  final List<String> _tags = [];
  bool _allowDisruption = false;
  int _disruptionIntensity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final db = ref.read(appDatabaseProvider);
    final schedule = await (db.select(db.schedules)
          ..where((s) => s.id.equals(widget.scheduleId!)))
        .getSingleOrNull();
    if (schedule == null || !mounted) return;
    setState(() {
      _titleController.text = schedule.title;
      _category = ScheduleCategory.fromString(schedule.category);
      _isTodo = schedule.isTodo;
      _allowDisruption = schedule.allowDisruption;
      _disruptionIntensity = schedule.disruptionIntensity;
      if (schedule.startTime != null) {
        _selectedDate = DateTime(
          schedule.startTime!.year,
          schedule.startTime!.month,
          schedule.startTime!.day,
        );
        if (!schedule.isTodo) {
          _startTime = TimeOfDay.fromDateTime(schedule.startTime!);
        }
      }
      if (schedule.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(schedule.endTime!);
      }
      try {
        final decoded = jsonDecode(schedule.tags);
        if (decoded is List) {
          _tags
            ..clear()
            ..addAll(decoded.cast<String>());
        }
      } on FormatException catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authProvider).value?.id ?? 'local';

    final date = _selectedDate ?? DateTime.now();
    DateTime? startDt;
    DateTime? endDt;

    if (_isTodo) {
      // Todos persist date-only with time pinned to 00:00 so the weekly grid
      // can surface them in its "할일" section.
      startDt = DateTime(date.year, date.month, date.day);
      endDt = null;
    } else {
      if (_startTime != null) {
        startDt = DateTime(
          date.year,
          date.month,
          date.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }
      if (_endTime != null) {
        endDt = DateTime(
          date.year,
          date.month,
          date.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }
    }

    final notifier = ref.read(scheduleActionsProvider.notifier);
    if (widget.scheduleId != null) {
      await notifier.updateSchedule(
        id: widget.scheduleId!,
        title: _titleController.text.trim(),
        category: _category.name,
        tags: _tags,
        startTime: Value(startDt),
        endTime: Value(endDt),
        isTodo: _isTodo,
        allowDisruption: _allowDisruption,
        disruptionIntensity: _disruptionIntensity,
      );
    } else {
      await notifier.create(
        userId: userId,
        title: _titleController.text.trim(),
        category: _category.name,
        tags: _tags,
        startTime: startDt,
        endTime: endDt,
        isTodo: _isTodo,
        allowDisruption: _allowDisruption,
        disruptionIntensity: _disruptionIntensity,
      );
    }

    if (mounted) context.pop();
  }

  Future<void> _onAllowDisruptionChanged(bool value) async {
    setState(() => _allowDisruption = value);
    if (!value) return;
    final api = DisturbanceApi();
    final missing = <_MissingPermission>[];
    if (!await api.isNotificationPermissionGranted()) {
      missing.add(_MissingPermission.notification);
    }
    if (!await api.isOverlayPermissionGranted()) {
      missing.add(_MissingPermission.overlay);
    }
    if (!await api.isBatteryOptimizationIgnored()) {
      missing.add(_MissingPermission.battery);
    }
    if (!mounted || missing.isEmpty) return;
    await _showMissingPermissionsDialog(api, missing);
  }

  Future<void> _showMissingPermissionsDialog(
    DisturbanceApi api,
    List<_MissingPermission> missing,
  ) async {
    final next = await showDialog<_MissingPermission>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('방해 허용에 권한이 필요해요'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('아래 권한을 차례로 허용해 주세요.'),
            const SizedBox(height: 12),
            for (final p in missing)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${p.label} — ${p.reason}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, missing.first),
            child: Text('${missing.first.label} 부여'),
          ),
        ],
      ),
    );
    if (next == null) return;
    switch (next) {
      case _MissingPermission.notification:
        await api.openNotificationSettings();
      case _MissingPermission.overlay:
        await api.requestOverlayPermission();
      case _MissingPermission.battery:
        await api.requestBatteryOptimizationExemption();
    }
  }

  Future<void> _onIntensityChanged(int? value) async {
    if (value == null) return;
    setState(() => _disruptionIntensity = value);
    if (value != 3) return;
    final api = DisturbanceApi();
    final active = await api.isDeviceAdminActive();
    if (!mounted || active) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기기 관리자 권한이 필요해요'),
        content: const Text(
          'L3 강도는 일정 중 휴대폰 화면을 잠가 집중을 보호합니다.\n'
          '시스템 설정에서 "루틴몬"을 기기 관리자로 활성화하면 동작합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('활성화'),
          ),
        ],
      ),
    );
    if (go == true) {
      await api.requestDeviceAdmin();
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  static const Map<ScheduleCategory, String> _categoryLabels = {
    ScheduleCategory.work: '업무',
    ScheduleCategory.study: '공부',
    ScheduleCategory.hobby: '취미',
    ScheduleCategory.health: '건강',
    ScheduleCategory.etc: '기타',
  };

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? '일정 편집' : '일정 추가')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ScheduleCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: ScheduleCategory.values
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(_categoryLabels[cat] ?? cat.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('할일 (시간 지정 없이 해당 날짜 마감)'),
              subtitle: _allowDisruption
                  ? const Text('방해 허용이 켜져 있어 사용할 수 없어요.')
                  : null,
              value: _isTodo,
              onChanged: _allowDisruption
                  ? null
                  : (v) => setState(() => _isTodo = v),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                _selectedDate != null
                    ? '날짜: ${_formatDate(_selectedDate!)}'
                    : '날짜 선택 (기본: 오늘)',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final initial = _selectedDate ?? DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 90)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            if (!_isTodo) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _startTime != null
                            ? '시작: ${_startTime!.format(context)}'
                            : '시작 시간',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (t != null) setState(() => _startTime = t);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _endTime != null
                            ? '종료: ${_endTime!.format(context)}'
                            : '종료 시간',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (t != null) setState(() => _endTime = t);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: '태그 추가',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: _tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          onDeleted: () =>
                              setState(() => _tags.remove(tag)),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('방해 허용'),
              subtitle: Text(
                _isTodo
                    ? '할일 모드에서는 사용할 수 없어요.'
                    : '일정 중 다른 앱 사용 시 강도별로 개입해요.',
              ),
              value: _allowDisruption,
              onChanged: _isTodo ? null : _onAllowDisruptionChanged,
            ),
            if (_allowDisruption) ...[
              RadioListTile<int>(
                title: const Text('L0 — 기록만 (방해 없음)'),
                subtitle: const Text(
                  '일정 중 다른 앱 사용 시 패키지·시간만 기록합니다.',
                ),
                value: 0,
                groupValue: _disruptionIntensity,
                onChanged: _onIntensityChanged,
              ),
              RadioListTile<int>(
                title: const Text('L1 — 짧은 진동 + 검은 화면 5초'),
                value: 1,
                groupValue: _disruptionIntensity,
                onChanged: _onIntensityChanged,
              ),
              RadioListTile<int>(
                title: const Text('L2 — 진동 + 차단 다이얼로그 + 홈으로 이동'),
                value: 2,
                groupValue: _disruptionIntensity,
                onChanged: _onIntensityChanged,
              ),
              RadioListTile<int>(
                title: const Text('L3 — 강한 진동 + 차단 + 주기적 화면 잠금'),
                subtitle: const Text('기기 관리자 권한 필요'),
                value: 3,
                groupValue: _disruptionIntensity,
                onChanged: _onIntensityChanged,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.isEdit ? '수정' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MissingPermission {
  notification('알림', '진행 중 알림 표시에 필요'),
  overlay('다른 앱 위에 표시', '홈 강제 이동 (BAL 우회)에 필요'),
  battery('배터리 최적화 제외', 'background 동작 안정성 확보');

  const _MissingPermission(this.label, this.reason);
  final String label;
  final String reason;
}

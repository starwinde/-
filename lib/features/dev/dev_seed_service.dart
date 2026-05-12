// Dev-only 시드. 디버그 빌드 한정 — 촬영 데모 / 정산 검증용.
//
// 이번 주(월~일) 의 일정 10건 + 대응 세션 (focusRatio 1.0) + isCompleted=true
// 를 한 번에 시드한다. 'dev-seed' 태그로 마킹되어 재호출 시 이전 시드만
// soft-delete 한 뒤 새로 만든다 (멱등).

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

part 'dev_seed_service.g.dart';

class DevSeedSummary {
  const DevSeedSummary({
    required this.weekStart,
    required this.schedulesInserted,
    required this.sessionsInserted,
  });
  final DateTime weekStart;
  final int schedulesInserted;
  final int sessionsInserted;
}

class DevSeedService {
  DevSeedService(this._db);
  final AppDatabase _db;

  /// 시드 entry 식별 태그 (멱등 마킹).
  static const _seedTag = 'dev-seed';

  /// [now] 가 속한 주의 월요일을 0시로 반환.
  static DateTime mondayOf(DateTime now) {
    final local = DateTime(now.year, now.month, now.day);
    final delta = (local.weekday - DateTime.monday) % 7;
    return local.subtract(Duration(days: delta));
  }

  /// 시드 실행. 같은 사용자에 대해 호출하면 이전 dev-seed 데이터를
  /// soft-delete (schedules) + 삭제 (sessions) 후 새 데이터로 교체.
  Future<DevSeedSummary> seedWeek({required String userId, DateTime? now}) async {
    final base = mondayOf(now ?? DateTime.now());
    return _db.transaction(() async {
      // 깨끗한 테스트 환경 — user 의 모든 schedules soft-delete,
      // sessions / dailyScores 는 통째로 wipe.
      await (_db.update(_db.schedules)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull()))
          .write(SchedulesCompanion(deletedAt: Value(DateTime.now())));
      await (_db.delete(_db.sessions)
            ..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.dailyScores)
            ..where((t) => t.userId.equals(userId)))
          .go();

      final entries = _weeklyTemplate(base);
      var schedulesInserted = 0;
      var sessionsInserted = 0;
      for (final e in entries) {
        final entryStart = e.start;
        final entryEnd = e.end;
        final scheduleId = await _db.into(_db.schedules).insert(
              SchedulesCompanion.insert(
                userId: userId,
                title: e.title,
                category: e.category,
                tags: Value(jsonEncode([_seedTag, ...e.tags])),
                startTime: entryStart == null
                    ? const Value<DateTime?>(null)
                    : Value<DateTime>(entryStart),
                endTime: entryEnd == null
                    ? const Value<DateTime?>(null)
                    : Value<DateTime>(entryEnd),
                isTodo: const Value(true),
                isCompleted: const Value(true),
              ),
            );
        schedulesInserted++;
        // 시간 미지정 entry 는 세션 생성 생략 — todos 만 집계됨.
        final start = entryStart;
        final end = entryEnd;
        if (start == null || end == null) continue;
        // 대응 세션: 계획 == 실제 (focusRatio = 1.0)
        final plannedMin = end.difference(start).inMinutes;
        await _db.into(_db.sessions).insert(
              SessionsCompanion.insert(
                userId: userId,
                remoteId: const Value(_seedTag),
                scheduleId: Value(scheduleId),
                startTime: start,
                endTime: Value(end),
                plannedDurationMin: Value(plannedMin),
                actualFocusMin: Value(plannedMin),
                blacklistUsageMin: const Value(0),
                focusRatio: const Value(1.0),
                grade: const Value('S'),
                isActive: const Value(false),
              ),
            );
        sessionsInserted++;
      }
      return DevSeedSummary(
        weekStart: base,
        schedulesInserted: schedulesInserted,
        sessionsInserted: sessionsInserted,
      );
    });
  }

  List<_Entry> _weeklyTemplate(DateTime monday) {
    final out = <_Entry>[];
    // 평일 5일: 핵심 업무 9-11 (시간 지정)
    for (var d = 0; d < 5; d++) {
      final day = monday.add(Duration(days: d));
      out.add(_Entry(
        title: '핵심 업무',
        category: 'work',
        tags: const ['focus'],
        start: DateTime(day.year, day.month, day.day, 9),
        end: DateTime(day.year, day.month, day.day, 11),
      ));
    }
    // 월/수/금 운동 18:30-19:30 (시간 지정)
    for (final d in [0, 2, 4]) {
      final day = monday.add(Duration(days: d));
      out.add(_Entry(
        title: '운동',
        category: 'health',
        tags: const ['exercise'],
        start: DateTime(day.year, day.month, day.day, 18, 30),
        end: DateTime(day.year, day.month, day.day, 19, 30),
      ));
    }
    // 평일 5일: 시간 미지정(day-only) to-do — 독서/메모/회고 교차 배치.
    // UI 의 weekly_grid_view 는 startTime = day 00:00 + endTime = null 을
    // "dayOnly" 슬롯으로 인식해 별도 섹션에 표시한다.
    const dailyFreeTitles = <int, ({String title, String category, String tag})>{
      0: (title: '독서 30분', category: 'self', tag: 'read'),
      1: (title: '하루 메모', category: 'self', tag: 'journal'),
      2: (title: '독서 30분', category: 'self', tag: 'read'),
      3: (title: '하루 메모', category: 'self', tag: 'journal'),
      4: (title: '주간 회고 준비', category: 'self', tag: 'reflect'),
    };
    dailyFreeTitles.forEach((d, info) {
      final day = monday.add(Duration(days: d));
      out.add(_Entry(
        title: info.title,
        category: info.category,
        tags: [info.tag, 'day-only'],
        start: DateTime(day.year, day.month, day.day),
      ));
    });
    // 토요일 — 취미·자기계발 (시간 지정)
    final sat = monday.add(const Duration(days: 5));
    out.add(_Entry(
      title: '취미·자기계발',
      category: 'hobby',
      tags: const ['weekend'],
      start: DateTime(sat.year, sat.month, sat.day, 10),
      end: DateTime(sat.year, sat.month, sat.day, 12),
    ));
    // 일요일 — 시간 미지정 주간 회고 (day-only)
    final sun = monday.add(const Duration(days: 6));
    out.add(_Entry(
      title: '주간 회고',
      category: 'self',
      tags: const ['weekend', 'day-only', 'reflect'],
      start: DateTime(sun.year, sun.month, sun.day),
    ));
    return out;
  }
}

class _Entry {
  const _Entry({
    required this.title,
    required this.category,
    required this.tags,
    this.start,
    this.end,
  });
  final String title;
  final String category;
  final List<String> tags;
  final DateTime? start;
  final DateTime? end;
}

@riverpod
DevSeedService devSeedService(Ref ref) =>
    DevSeedService(ref.watch(appDatabaseProvider));

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/disturbance/data/usage_log_repository.dart';

void main() {
  late AppDatabase db;
  late UsageLogRepository repo;
  const userId = 'tester';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UsageLogRepository(db);
  });

  tearDown(() => db.close());

  group('UsageLogRepository', () {
    test('insert creates row with all fields', () async {
      final start = DateTime(2026, 5, 3, 10);
      final end = DateTime(2026, 5, 3, 10, 5);
      final id = await repo.insert(
        userId: userId,
        scheduleId: 42,
        packageName: 'com.android.chrome',
        totalMs: 60000,
        rangeStart: start,
        rangeEnd: end,
      );
      expect(id, greaterThan(0));
      final rows = await db.select(db.usageLogs).get();
      expect(rows, hasLength(1));
      expect(rows.first.userId, userId);
      expect(rows.first.scheduleId, 42);
      expect(rows.first.packageName, 'com.android.chrome');
      expect(rows.first.totalMs, 60000);
    });

    test('insert with null scheduleId allowed', () async {
      await repo.insert(
        userId: userId,
        packageName: 'com.foo',
        totalMs: 1000,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3, 0, 1),
      );
      final rows = await db.select(db.usageLogs).get();
      expect(rows.first.scheduleId, isNull);
    });

    test('insertMany inserts in transaction', () async {
      final companions = [
        UsageLogsCompanion.insert(
          userId: userId,
          packageName: 'com.a',
          totalMs: 100,
          rangeStart: DateTime(2026, 5, 3),
          rangeEnd: DateTime(2026, 5, 3, 0, 1),
        ),
        UsageLogsCompanion.insert(
          userId: userId,
          packageName: 'com.b',
          totalMs: 200,
          rangeStart: DateTime(2026, 5, 3),
          rangeEnd: DateTime(2026, 5, 3, 0, 1),
        ),
      ];
      final ids = await repo.insertMany(companions);
      expect(ids, hasLength(2));
    });

    test('insertMany with empty list is no-op', () async {
      final ids = await repo.insertMany(const []);
      expect(ids, isEmpty);
    });

    test('getForDate returns rows captured on that date only', () async {
      // Captured today
      await repo.insert(
        userId: userId,
        packageName: 'com.today',
        totalMs: 100,
        rangeStart: DateTime.now(),
        rangeEnd: DateTime.now(),
      );
      // Backdate one row's capturedAt by direct DB write.
      await db.into(db.usageLogs).insert(
            UsageLogsCompanion.insert(
              userId: userId,
              packageName: 'com.yesterday',
              totalMs: 100,
              rangeStart: DateTime(2025, 1, 1),
              rangeEnd: DateTime(2025, 1, 1),
              capturedAt: Value(DateTime(2025, 1, 1, 12)),
            ),
          );
      final today = await repo.getForDate(userId, DateTime.now());
      expect(today.map((e) => e.packageName), contains('com.today'));
      expect(today.map((e) => e.packageName), isNot(contains('com.yesterday')));
    });

    test('getForSchedule filters by scheduleId', () async {
      await repo.insert(
        userId: userId,
        scheduleId: 1,
        packageName: 'com.a',
        totalMs: 100,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3),
      );
      await repo.insert(
        userId: userId,
        scheduleId: 2,
        packageName: 'com.b',
        totalMs: 200,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3),
      );
      final s1 = await repo.getForSchedule(userId, 1);
      expect(s1, hasLength(1));
      expect(s1.first.packageName, 'com.a');
    });

    test('aggregateTopPackages sums totalMs and limits to N', () async {
      // Three packages, com.b is largest
      await repo.insert(
        userId: userId,
        packageName: 'com.a',
        totalMs: 1000,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3),
      );
      await repo.insert(
        userId: userId,
        packageName: 'com.b',
        totalMs: 5000,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3),
      );
      await repo.insert(
        userId: userId,
        packageName: 'com.b',
        totalMs: 3000,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3),
      );
      await repo.insert(
        userId: userId,
        packageName: 'com.c',
        totalMs: 2000,
        rangeStart: DateTime(2026, 5, 3),
        rangeEnd: DateTime(2026, 5, 3),
      );
      final top = await repo.aggregateTopPackages(
        userId: userId,
        since: DateTime(2026, 5, 1),
        limit: 2,
      );
      expect(top, hasLength(2));
      expect(top[0].packageName, 'com.b');
      expect(top[0].totalMs, 8000);
      expect(top[1].packageName, 'com.c');
    });

    test('aggregateTopPackages excludes rows before since', () async {
      // Old row - explicit older capturedAt
      await db.into(db.usageLogs).insert(
            UsageLogsCompanion.insert(
              userId: userId,
              packageName: 'com.old',
              totalMs: 9999,
              rangeStart: DateTime(2024, 1, 1),
              rangeEnd: DateTime(2024, 1, 1),
              capturedAt: Value(DateTime(2024, 1, 1)),
            ),
          );
      // Recent row
      await repo.insert(
        userId: userId,
        packageName: 'com.new',
        totalMs: 100,
        rangeStart: DateTime.now(),
        rangeEnd: DateTime.now(),
      );
      final top = await repo.aggregateTopPackages(
        userId: userId,
        since: DateTime(2026, 1, 1),
      );
      expect(top.map((e) => e.packageName), isNot(contains('com.old')));
      expect(top.map((e) => e.packageName), contains('com.new'));
    });

    test('totalMsSince sums across packages', () async {
      await repo.insert(
        userId: userId,
        packageName: 'com.a',
        totalMs: 1000,
        rangeStart: DateTime.now(),
        rangeEnd: DateTime.now(),
      );
      await repo.insert(
        userId: userId,
        packageName: 'com.b',
        totalMs: 2000,
        rangeStart: DateTime.now(),
        rangeEnd: DateTime.now(),
      );
      final total = await repo.totalMsSince(
        userId: userId,
        since: DateTime(2026, 1, 1),
      );
      expect(total, 3000);
    });
  });

  group('Drift schemaVersion', () {
    test('AppDatabase reports schemaVersion=5 (PRD §2.6 v4→v5 PetInteractions)',
        () {
      expect(db.schemaVersion, 5);
    });

    test('usage_logs table created on fresh DB', () async {
      final cnt = await db.customSelect(
        'SELECT COUNT(*) AS c FROM usage_logs',
      ).getSingle();
      expect(cnt.read<int>('c'), 0);
    });
  });
}

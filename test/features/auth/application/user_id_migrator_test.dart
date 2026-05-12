// UserIdMigrator — 게스트 'local' → 인증 user id 이관 회로.

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/auth/application/user_id_migrator.dart';

void main() {
  late AppDatabase db;
  late UserIdMigrator migrator;
  const newId = 'uuid-new-user';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    migrator = UserIdMigrator(db);
  });

  tearDown(() => db.close());

  Future<void> seedAllTables(String userId) async {
    await db.into(db.schedules).insert(
          SchedulesCompanion.insert(
            userId: userId,
            title: '회의',
            category: 'work',
          ),
        );
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            userId: userId,
            startTime: DateTime(2026, 5, 12, 9),
          ),
        );
    final petId = await db.into(db.pets).insert(
          PetsCompanion.insert(
            userId: userId,
            species: 'bird',
            name: 'guest-pet',
          ),
        );
    await db.into(db.petInteractions).insert(
          PetInteractionsCompanion.insert(
            userId: userId,
            petId: petId,
            actionType: 'feed',
          ),
        );
    await db.into(db.dailyScores).insert(
          DailyScoresCompanion.insert(
            userId: userId,
            date: DateTime(2026, 5, 12),
            grade: 'S',
          ),
        );
    await db.into(db.usageLogs).insert(
          UsageLogsCompanion.insert(
            userId: userId,
            packageName: 'com.test',
            totalMs: 5 * 60 * 1000,
            rangeStart: DateTime(2026, 5, 12, 11),
            rangeEnd: DateTime(2026, 5, 12, 11, 5),
          ),
        );
  }

  Future<int> countWithUserId(String userId) async {
    final s = await (db.select(db.schedules)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final ses = await (db.select(db.sessions)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final p = await (db.select(db.pets)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final pi = await (db.select(db.petInteractions)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final ds = await (db.select(db.dailyScores)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final u = await (db.select(db.usageLogs)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return s.length + ses.length + p.length + pi.length + ds.length + u.length;
  }

  group('UserIdMigrator.migrateFromGuest', () {
    test('6 테이블 local row 를 새 user id 로 이관', () async {
      await seedAllTables(guestUserId);
      expect(await countWithUserId(guestUserId), 6);
      expect(await countWithUserId(newId), 0);

      final updated = await migrator.migrateFromGuest(newUserId: newId);
      expect(updated, 6);
      expect(await countWithUserId(guestUserId), 0);
      expect(await countWithUserId(newId), 6);
    });

    test('멱등성: local row 없으면 0건 반환', () async {
      await seedAllTables(newId); // 이미 마이그레이션된 상태
      final updated = await migrator.migrateFromGuest(newUserId: newId);
      expect(updated, 0);
      expect(await countWithUserId(newId), 6);
    });

    test('빈 문자열 / guest sentinel newUserId → no-op', () async {
      await seedAllTables(guestUserId);
      expect(await migrator.migrateFromGuest(newUserId: ''), 0);
      expect(
        await migrator.migrateFromGuest(newUserId: guestUserId),
        0,
      );
      expect(await countWithUserId(guestUserId), 6);
    });

    test('다른 user 의 데이터는 영향 받지 않음', () async {
      await seedAllTables(guestUserId);
      await seedAllTables('other-user');

      await migrator.migrateFromGuest(newUserId: newId);

      expect(await countWithUserId(guestUserId), 0);
      expect(await countWithUserId(newId), 6);
      expect(await countWithUserId('other-user'), 6);
    });
  });
}

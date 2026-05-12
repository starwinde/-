// 게스트 → 인증 전환 시 'local' userId 데이터를 실제 user id 로 이관.
//
// 게스트 모드(rev 27) 는 모든 데이터 화면에서 `auth?.id ?? 'local'` 폴백을
// 쓴다 (lib/features/*/presentation 18곳). 사용자가 로그인하면 새 user_id
// 가 발급되는데, 마이그레이션이 없으면 'local' 데이터는 orphan 으로 남아
// 화면에서 사라진 것처럼 보인다. 본 서비스가 로그인 직후 단일 트랜잭션으로
// 6 테이블 UPDATE 한다.

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart'
    show appDatabaseProvider;

part 'user_id_migrator.g.dart';

/// 게스트 sentinel — `?? 'local'` 폴백 패턴의 단일 진실 원천.
const String guestUserId = 'local';

class UserIdMigrator {
  UserIdMigrator(this._db);

  final AppDatabase _db;

  /// `'local'` userId 가진 모든 row 를 [newUserId] 로 이관.
  ///
  /// 멱등성: 이관 후 'local' row 가 없으면 0건 반환. [newUserId] 가
  /// [guestUserId] 와 같거나 빈 문자열이면 no-op.
  ///
  /// Returns: 테이블별 갱신 row 수의 합계 (디버그/관측용).
  Future<int> migrateFromGuest({required String newUserId}) async {
    if (newUserId.isEmpty || newUserId == guestUserId) return 0;
    return _db.transaction(() async {
      var total = 0;
      total += await (_db.update(_db.schedules)
            ..where((t) => t.userId.equals(guestUserId)))
          .write(SchedulesCompanion(userId: Value(newUserId)));
      total += await (_db.update(_db.sessions)
            ..where((t) => t.userId.equals(guestUserId)))
          .write(SessionsCompanion(userId: Value(newUserId)));
      total += await (_db.update(_db.pets)
            ..where((t) => t.userId.equals(guestUserId)))
          .write(PetsCompanion(userId: Value(newUserId)));
      total += await (_db.update(_db.petInteractions)
            ..where((t) => t.userId.equals(guestUserId)))
          .write(PetInteractionsCompanion(userId: Value(newUserId)));
      total += await (_db.update(_db.dailyScores)
            ..where((t) => t.userId.equals(guestUserId)))
          .write(DailyScoresCompanion(userId: Value(newUserId)));
      total += await (_db.update(_db.usageLogs)
            ..where((t) => t.userId.equals(guestUserId)))
          .write(UsageLogsCompanion(userId: Value(newUserId)));
      return total;
    });
  }
}

@riverpod
UserIdMigrator userIdMigrator(Ref ref) {
  return UserIdMigrator(ref.watch(appDatabaseProvider));
}

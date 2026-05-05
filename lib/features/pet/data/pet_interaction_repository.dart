import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';

part 'pet_interaction_repository.g.dart';

/// PRD §2.6 펫 인터랙션 액션 종류.
enum PetActionType {
  /// 먹이 — +5 HP, 일일 1회.
  feed,

  /// 쓰다듬기 — 친밀도+, 일일 3회.
  pet,

  /// 놀아주기 — +5 XP, 일일 1회.
  play,
}

extension PetActionTypeName on PetActionType {
  /// DB 저장용 문자열.
  String get wireName => switch (this) {
        PetActionType.feed => 'feed',
        PetActionType.pet => 'pet',
        PetActionType.play => 'play',
      };
}

/// `pet_interactions` 테이블 CRUD + 일일/누적 카운트.
class PetInteractionRepository {
  PetInteractionRepository(this._db);

  final AppDatabase _db;

  /// 새 인터랙션 행을 추가하고 outbox 에 enqueue.
  Future<int> insert({
    required int petId,
    required String userId,
    required PetActionType action,
    DateTime? performedAt,
  }) async {
    final at = performedAt ?? DateTime.now();
    final id = await _db.into(_db.petInteractions).insert(
          PetInteractionsCompanion.insert(
            petId: petId,
            userId: userId,
            actionType: action.wireName,
            performedAt: Value(at),
          ),
        );
    await _db.into(_db.outbox).insert(
          OutboxCompanion.insert(
            targetTable: 'pet_interactions',
            rowId: id.toString(),
            operation: 'insert',
            payload: jsonEncode(<String, Object?>{
              'pet_id': petId,
              'user_id': userId,
              'action_type': action.wireName,
              'performed_at': at.millisecondsSinceEpoch,
            }),
          ),
        );
    return id;
  }

  /// 오늘 (로컬 자정 기준) 같은 펫에 대한 [action] 적용 횟수.
  /// 일일 한도 검증용.
  Future<int> countTodayByAction({
    required int petId,
    required PetActionType action,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final dayStart =
        DateTime(reference.year, reference.month, reference.day);
    final rows = await (_db.select(_db.petInteractions)
          ..where(
            (t) =>
                t.petId.equals(petId) &
                t.actionType.equals(action.wireName) &
                t.performedAt.isBiggerOrEqualValue(dayStart),
          ))
        .get();
    return rows.length;
  }

  /// [petId] 의 평생 누적 [action] 카운트 — 친밀도 (action=pet) 노출 등.
  Future<int> countAllByAction({
    required int petId,
    required PetActionType action,
  }) async {
    final rows = await (_db.select(_db.petInteractions)
          ..where(
            (t) => t.petId.equals(petId) & t.actionType.equals(action.wireName),
          ))
        .get();
    return rows.length;
  }

  /// 펫의 모든 인터랙션 행 (UI 전용).
  Future<List<PetInteraction>> getAllForPet(int petId) {
    return (_db.select(_db.petInteractions)
          ..where((t) => t.petId.equals(petId))
          ..orderBy([(t) => OrderingTerm.desc(t.performedAt)]))
        .get();
  }
}

/// Riverpod provider.
@riverpod
PetInteractionRepository petInteractionRepository(Ref ref) {
  return PetInteractionRepository(ref.watch(appDatabaseProvider));
}

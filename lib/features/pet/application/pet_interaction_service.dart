import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:routinemon/features/pet/data/pet_interaction_repository.dart';
import 'package:routinemon/features/pet/data/pet_repository.dart';
import 'package:routinemon/features/pet/domain/hp_curve.dart' as hp_curve;

part 'pet_interaction_service.g.dart';

/// 인터랙션 결과 — UI 가 SnackBar/Toast 등에 표시.
class PetInteractionResult {
  /// Successful application of an interaction.
  const PetInteractionResult({
    required this.action,
    required this.hpDelta,
    required this.xpDelta,
    required this.newHp,
    required this.newXp,
    this.success = true,
    this.dailyLimit,
  });

  /// 한도 초과 등으로 실패.
  factory PetInteractionResult.dailyLimit({
    required PetActionType action,
    required int dailyLimit,
  }) {
    return PetInteractionResult(
      action: action,
      hpDelta: 0,
      xpDelta: 0,
      newHp: 0,
      newXp: 0,
      success: false,
      dailyLimit: dailyLimit,
    );
  }

  /// 적용된 액션.
  final PetActionType action;

  /// HP 실제 변화량 (cap 적용 후 — overflow 분은 [xpDelta] 에 합산).
  final int hpDelta;

  /// XP 실제 변화량 (인터랙션 본 보상 + HP overflow 보너스 포함).
  final int xpDelta;

  /// 적용 후 HP.
  final int newHp;

  /// 적용 후 XP.
  final int newXp;

  /// false 면 일일 한도 초과로 무시.
  final bool success;

  /// 한도 초과 시 한도 값 (UI 메시지용).
  final int? dailyLimit;
}

/// PRD §2.6 펫 인터랙션 도메인 로직 + 일일 한도 강제.
///
/// 일일 한도: 먹이 1, 쓰다듬기 3, 놀아주기 1 (자정 reset, 로컬 시간).
/// 효과:
/// - feed: HP +5 (cap 100, overflow 2:1 → XP)
/// - pet: HP/XP 변경 없음, intimacy 누적
/// - play: XP +5
class PetInteractionService {
  /// Default daily limits.
  PetInteractionService({
    required PetRepository petRepo,
    required PetInteractionRepository interactionRepo,
  })  : _petRepo = petRepo,
        _interactionRepo = interactionRepo;

  final PetRepository _petRepo;
  final PetInteractionRepository _interactionRepo;

  /// 액션별 일일 한도.
  static const Map<PetActionType, int> dailyLimits = {
    PetActionType.feed: 1,
    PetActionType.pet: 3,
    PetActionType.play: 1,
  };

  /// 액션별 즉시 보상 (펫에 적용).
  static const int feedHpReward = 5;
  static const int playXpReward = 5;

  /// 일일 한도 검증 + 인터랙션 적용. 펫이 죽었거나 [userId] 와 무관하면
  /// throw — 호출자(UI) 가 펫 상태 확인 후 호출 책임.
  Future<PetInteractionResult> apply({
    required int petId,
    required String userId,
    required PetActionType action,
    DateTime? now,
  }) async {
    final limit = dailyLimits[action]!;
    final used = await _interactionRepo.countTodayByAction(
      petId: petId,
      action: action,
      now: now,
    );
    if (used >= limit) {
      return PetInteractionResult.dailyLimit(
        action: action,
        dailyLimit: limit,
      );
    }

    await _interactionRepo.insert(
      petId: petId,
      userId: userId,
      action: action,
      performedAt: now,
    );

    final pet = await _petRepo.getActivePet(userId);
    if (pet == null || pet.id != petId) {
      // 펫 변동 시 보상 없이 기록만 — UI 는 사망/리셋 케이스를 별도 처리.
      return PetInteractionResult(
        action: action,
        hpDelta: 0,
        xpDelta: 0,
        newHp: pet?.hp ?? 0,
        newXp: pet?.xp ?? 0,
      );
    }

    int newHp = pet.hp;
    int newXp = pet.xp;
    int hpDelta = 0;
    int xpDelta = 0;

    switch (action) {
      case PetActionType.feed:
        final result = hp_curve.applyHpChange(pet.hp, feedHpReward);
        newHp = result.newHp;
        newXp = pet.xp + result.overflowXp;
        hpDelta = newHp - pet.hp;
        xpDelta = result.overflowXp;
      case PetActionType.play:
        newXp = pet.xp + playXpReward;
        xpDelta = playXpReward;
      case PetActionType.pet:
        // intimacy 만 누적 — DB 행 자체가 카운트 (insert 위에서 완료).
        break;
    }

    if (hpDelta != 0 || xpDelta != 0) {
      await _petRepo.applySettlement(
        petId: petId,
        newXp: newXp,
        newHp: newHp,
        isAlive: pet.isAlive,
      );
    }

    return PetInteractionResult(
      action: action,
      hpDelta: hpDelta,
      xpDelta: xpDelta,
      newHp: newHp,
      newXp: newXp,
    );
  }
}

/// Riverpod provider.
@riverpod
PetInteractionService petInteractionService(Ref ref) {
  return PetInteractionService(
    petRepo: ref.watch(petRepositoryProvider),
    interactionRepo: ref.watch(petInteractionRepositoryProvider),
  );
}

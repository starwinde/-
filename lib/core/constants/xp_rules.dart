// XP/HP/진화 공식 단일 출처 (rules.md §3.6).
// 순수 Dart만 — Flutter import 금지 (rules.md §3.3).

/// 집중 세션 등급.
enum FocusGrade {
  /// >= 0.95
  s,

  /// >= 0.85
  a,

  /// >= 0.70
  b,

  /// >= 0.50
  c,

  /// < 0.50
  d,
}

/// 등급별 보상 정의.
class GradeReward {
  /// [minRatio] 이상일 때 [xp] / [hp] 보상.
  const GradeReward({
    required this.minRatio,
    required this.xp,
    required this.hp,
  });

  /// 최소 집중 비율.
  final double minRatio;

  /// 획득 XP.
  final int xp;

  /// HP 변화량.
  final int hp;
}

/// XP/HP/진화 상수 레지스트리.
class XpRules {
  const XpRules._();

  /// HP 최대값.
  static const maxHp = 100;

  /// HP 오버플로우 → XP 전환 제수.
  static const hpOverflowXpDivisor = 2;

  /// D등급 기본 HP 차감.
  static const hpWeightBaseDeduction = -10;

  /// D등급 연속 가중 증분.
  static const hpWeightIncrement = -5;

  /// 놀아주기 일일 XP 보너스.
  static const playXpPerDay = 5;

  /// S등급 5일 연속 보너스 XP.
  static const sStreak5BonusXp = 50;

  /// 책상 이탈 HP 패널티.
  static const deskAwayHpPenalty = -3;

  /// 책상 이탈 쿨다운(분).
  static const deskAwayCooldownMinutes = 30;

  /// 책상 이탈 일일 최대 패널티.
  static const deskAwayDailyMax = -9;

  /// 미완료 할일 HP 패널티.
  static const incompleteTaskHpPenalty = -3;

  /// 미완료 할일 일일 최대 패널티.
  static const incompleteTaskDailyMax = -15;

  /// 실시간 HP 감소 1 단위에 필요한 phone-use 누적 분.
  /// (방해 허용 일정 진행 중 3 분 사용 = -1 HP)
  static const realtimeHpMinutesPerDecrement = 3;

  /// 한 일정 안에서 가능한 실시간 HP 감소 횟수 상한 (= -5 HP).
  static const realtimeHpMaxDecrementsPerSchedule = 5;

  /// 하루(자정 기준) 누적 HP 손실 상한 — 실시간 + 정산 합산.
  static const dailyHpLossCap = 10;

  /// 친밀도 등급 임계값 (누적 쓰다듬기 횟수). rev 38, 2026-05-12.
  ///
  /// count < 10 → Lv 0 (보너스 0)
  /// 10 ≤ count < 20 → Lv 1 (+1 XP / 쓰다듬)
  /// 20 ≤ count < 30 → Lv 2 (+2 XP / 쓰다듬)
  /// 30 ≤ count       → Lv 3 (+3 XP / 쓰다듬)
  static const intimacyTierThresholds = <int>[10, 20, 30];

  /// 친밀도 Lv 0~3 에서 쓰다듬기 1회당 지급되는 추가 XP.
  static const intimacyTierBonusXp = <int>[0, 1, 2, 3];

  /// 등급별 보상 테이블.
  static const gradeRewards = <FocusGrade, GradeReward>{
    FocusGrade.s: GradeReward(minRatio: 0.95, xp: 30, hp: 15),
    FocusGrade.a: GradeReward(minRatio: 0.85, xp: 20, hp: 10),
    FocusGrade.b: GradeReward(minRatio: 0.70, xp: 10, hp: 5),
    FocusGrade.c: GradeReward(minRatio: 0.50, xp: 3, hp: 0),
    FocusGrade.d: GradeReward(minRatio: 0, xp: 0, hp: -10),
  };

  /// 새 진화 XP 임계값.
  static const birdEvolutionXp = [60, 210, 480, 900];

  /// 드래곤 진화 XP 임계값.
  static const dragonEvolutionXp = [200, 600, 1200];

  /// 돌고래 진화 XP 임계값.
  static const dolphinEvolutionXp = [250, 750, 1500];
}

/// 누적 친밀도 [count] 의 등급(0~3) 을 반환. rev 38.
int intimacyTierFor(int count) {
  if (count >= 30) return 3;
  if (count >= 20) return 2;
  if (count >= 10) return 1;
  return 0;
}

/// [count] 에서 다음 등급 임계값. 최고 등급이면 null.
int? nextIntimacyThreshold(int count) {
  if (count < 10) return 10;
  if (count < 20) return 20;
  if (count < 30) return 30;
  return null;
}

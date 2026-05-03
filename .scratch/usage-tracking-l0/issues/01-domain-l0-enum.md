# 01 — DisturbanceLevel L0 enum 확장

Status: done — 2026-05-03 (`DisturbanceLevel.l0` 추가, `fromInt(0)` 매핑, `onActiveUsage` L0 분기 빈 액션, 8/8 단위테스트 PASS)
의존성: 없음
관련 ADR: 0004

## 목적

`DisturbanceLevel` enum 에 `l0` 추가, `DisturbanceIntervention` 가 L0 입력 시 모든 액션 0/false 의 빈 `DisturbanceAction` 을 반환하도록 한다.

## 변경 파일

- `lib/features/disturbance/domain/disturbance_intervention.dart`
- `test/features/disturbance/domain/disturbance_intervention_test.dart` (신규 또는 확장)

## 작업

1. `enum DisturbanceLevel { l0, l1, l2, l3 }` 으로 확장. doc 한 줄로 L0 의 의미 명시: "기록만, 액션 없음".
2. `fromInt(int)` 의 `case 0: return l0;` 추가. default 는 기존 l1 유지 (안전 디폴트).
3. `onActiveUsage(now, level)` 의 switch 에 `case l0: return const DisturbanceAction(vibrateMs: 0);` (모든 필드 0/false default 활용). 쿨다운 갱신은 기존과 동일 (호출 빈도 일관성).
4. 단위 테스트:
   - `fromInt(0) == l0`
   - `fromInt(-1)` 또는 `fromInt(99)` 는 안전 폴백 → `l1`
   - L0 의 onActiveUsage 결과는 vibrateMs=0, blockDialog=false, periodicSec=0 등 액션 없음
   - 기존 L1/L2/L3 결과 회귀 0건

## DoD

- [ ] enum 4 값
- [ ] `fromInt` 매핑 4종 + 폴백 1종 단위 테스트 통과
- [ ] `flutter analyze` 0 warning
- [ ] `flutter test test/features/disturbance/` 회귀 0건

## 검증

- 단위 테스트만. UI 통합은 issue 04.

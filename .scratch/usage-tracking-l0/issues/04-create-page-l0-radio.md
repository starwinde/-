# 04 — schedule_create_page L0 라디오 추가

Status: done — 2026-05-03 (L0 RadioListTile 추가 (value=0, "기록만 (방해 없음)" + 부제), L1/L2/L3 회귀 0건. smoke 2/2 PASS)
의존성: 01
관련 ADR: 0004

## 목적

일정 생성/편집 화면의 방해 강도 라디오에 L0 옵션을 추가. 기존 L1/L2/L3 라벨·동작 유지.

## 변경 파일

- `lib/features/schedule/presentation/schedule_create_page.dart`
- `test/features/schedule/presentation/schedule_create_page_l0_test.dart` (신규)
- `test/features/schedule/presentation/schedule_create_page_edit_smoke_test.dart` (회귀 보강)

## UI 변경

기존 (L1/L2/L3 3 라디오) 위에 신규 추가:

```dart
RadioListTile<int>(
  title: const Text('L0 — 기록만 (방해 없음)'),
  subtitle: const Text('일정 중 다른 앱 사용 시 패키지·시간만 기록합니다.'),
  value: 0,
  groupValue: _disruptionIntensity,
  onChanged: _onIntensityChanged,
),
```

`_onIntensityChanged(0)` 는 DEVICE_ADMIN 다이얼로그를 표시하지 않는다 (조건 `if (value != 3) return;` 으로 자연 스킵).

## 기본값 정책

- 신규 일정: `_disruptionIntensity = 1` 유지 (기존 동작).
- 사용자가 명시 선택할 때만 0 세팅.

## 단위 테스트

- L0 라디오 노출 + 선택 시 `_disruptionIntensity = 0`
- L0 선택 후 저장 시 DB 에 0 으로 기록 (drift integration)
- L1/L2/L3 회귀 테스트 4종 (라디오 노출 + 선택 + 저장)

## DoD

- [ ] L0 라디오 노출
- [ ] L0 선택 후 저장 → DB intensity=0
- [ ] L1/L2/L3 회귀 0건
- [ ] `flutter analyze` 0 warning, `flutter test` 회귀 0건

## 검증

- widget 테스트
- 실기기 통합은 issue 05

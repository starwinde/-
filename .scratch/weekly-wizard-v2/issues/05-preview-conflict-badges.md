# 05 — Preview UI: conflict 뱃지 + source 라벨

Status: done
의존성: 04
관련 ADR: 0002
완료: 2026-05-03 — conflict 뱃지 (severity 기반), source 칩 (기본/AI 향상/폴백), summary banner, 충돌 sheet, error 시 confirm dialog. widget 6/6 PASS, 0 warning.

## 목적

`WizardPreviewPage` 가 `WeeklyWizardResponse.conflicts` 와 각 item 의 `source` 를 시각화. 사용자가 충돌을 인지하고 수동 처리할 수 있게 한다.

## 변경/신규 파일

- `lib/features/schedule/presentation/wizard_preview_page.dart` (수정)
- `test/features/schedule/presentation/wizard_preview_page_test.dart` (신규 또는 확장)

## 설계 메모

### UI 변경

각 ListTile leading 또는 trailing 에:
- `ConflictKind.timeOverlap`/`existingOverlap` → `Icon(Icons.error, color: red)` + tap 가능
- `noBreak`/`categoryMonotony`/`outsideAwake` → `Icon(Icons.warning, color: orange)` + tap 가능
- 충돌 없음 → 뱃지 없음

`source` 라벨 (subtitle 끝에):
- `WizardSource.rule` → 회색 칩 "기본"
- `WizardSource.llm` → 보라 칩 "AI 향상"
- `WizardSource.preset` → 회색 칩 "기본 (폴백)"

행 탭 → `showModalBottomSheet`:
- 충돌 종류 한국어 메시지
- 영향 받는 다른 행 인덱스 → ListView 안에서 스크롤 + 하이라이트

`_apply()` 에서:
- 적용 직전 conflicts 에 `severity = error` 가 있으면 confirm dialog 표시 ("충돌 N건 — 그래도 적용?")
- 사용자가 cancel 하면 적용 중단

### Show conflicts summary banner

페이지 상단에 conflicts.length > 0 시 `Banner` (`error N건 / warning M건`).

## DoD

- [ ] 각 item 행에 conflict 뱃지 표시 (해당 인덱스가 conflicts.indices 에 있을 때)
- [ ] source 라벨 ("기본"/"AI 향상"/"기본 (폴백)") 표시
- [ ] 행 탭 → 충돌 상세 sheet, 영향 행 하이라이트
- [ ] 페이지 상단 conflicts summary banner
- [ ] error severity 충돌 + 적용 → confirm dialog → cancel 시 미적용
- [ ] widget 테스트 ≥ 5
- [ ] `flutter analyze` 0 warning

## 검증

- widget 테스트 + Storybook 풍 manual smoke
- 회귀 0건

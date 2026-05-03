# 03 — Gmail API + 로컬 LLM NLP via n8n 워크플로우

Status: in-progress

## 출처

Tasks.md `T5.11` — Block A1 완료 (2026-04-18, rev 10). Gmail fetch + OAuth 연동은 T5.0 사용자 액션 후 Block C 로 이월.

## 설명

n8n 워크플로우 `routinemon-auto-schedule` 가 Gmail 메시지를 받아 로컬 LLM 으로 일정 추출. Flutter 가 호출하여 결과를 Drift 에 INSERT.

## 완료된 부분 (Block A1, 2026-04-18)

- n8n 워크플로우 `routinemon-auto-schedule` (ID `NrqMGblcgsOTX0f4`, active)
- Flutter `AutoScheduleService` + freezed 모델 (`AutoScheduleRequest`, `AutoScheduleResponse`, `Source`)
- TDD: unit 9 + integration 3 = 12 tests passed
- smoke 3/3 검증 (LLM 경로 1 + preset fallback 2)
- analyze 0 error/warning

## 남은 작업 (Block C 예정)

- [ ] Gmail API `messages.list` + `messages.get` 호출 (사용자 OAuth 토큰)
- [ ] 메시지 본문 → `routinemon-auto-schedule` 워크플로우 입력 변환
- [ ] LLM 응답 → Drift `schedules` INSERT 파이프라인 결합
- [ ] 실기기 한국어 메시지 1건 이상 E2E 검증

## 차단

01 (OAuth Client ID) 완료 후 진입 가능. 그 전까지 in-progress 상태로 워크플로우/모델만 유지.

## DoD

- 실기기에서 Gmail 메시지 → 일정 자동 등록 동작
- 회귀 0건

## Comments

- 2026-04-18: Block A1 완료. n8n 워크플로우 + Service 레이어까지 구현. T5.0 사용자 액션 대기.

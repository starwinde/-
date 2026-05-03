# auto-schedule — Feature PRD

> Phase 5 의 자동 스케줄 블록을 거버넌스 전환(2026-05-03) 시점에 이 디렉터리로 이주.
> 루트 `PRD.md` 의 해당 섹션은 단일 진실 원천(SoT) 으로 유지되며, 이 파일은 feature 단위 작업 컨텍스트.

## 목적

Gmail / 카카오톡 등에서 받은 메시지를 NLP 로 분석해 사용자의 주간 일정에 자동 등록. Pro 차별화 기능의 한 축.

## 범위

- Google OAuth 2.0 (Desktop/Android Client ID) — Gmail API + Google Calendar API scope
- Google Calendar 일정 읽기 (읽기 전용)
- Gmail 메시지 → 로컬 LLM (n8n `routinemon-auto-schedule` workflow) → 일정 추출 → Drift `schedules` 테이블 INSERT
- Share intent (카카오톡 / 슬랙 메시지 공유) → 동일 NLP 파이프라인

## 비범위

- Calendar 쓰기 (양방향 동기화 v1.1+)
- 일정 충돌 자동 해결 (사용자가 수동으로 처리)
- 다국어 NLP (한국어 + 영어만 v1.0)

## 의존성

- T5.0 (P5.0 user action): Google Cloud OAuth Client ID + API 활성화 — 사용자 직접 수행 필요
- 로컬 LLM 백엔드: LM Studio `http://localhost:1234/v1` (`google/gemma-4-e4b`), n8n credential `LM Studio Local`
- n8n 워크플로우 `routinemon-auto-schedule` (ID `NrqMGblcgsOTX0f4`, active) — Block A1 단계에서 이미 active 상태

## DoD

- Google Calendar 일정 읽기 동작 (실기기)
- Gmail 메시지 → NLP → Drift 자동 INSERT (실기기, 한국어 메시지 1건 이상 검증)
- Share intent 처리 동작 (카톡 메시지 공유 → 일정 등록)
- analytics: `auto_schedule_imported` 이벤트 발생
- flutter test 회귀 0건, analyze 0 warning

## 진행 상황 (Block A1 — 2026-04-18 완료분)

n8n 워크플로우 + Flutter `AutoScheduleService` + freezed 모델 (`AutoScheduleRequest/Response/Source`) 구현 완료. unit 9 + integration 3 = 12 tests passed. Gmail fetch + OAuth 연동은 T5.0 사용자 액션 후 진행 예정.

## 관련 ADR

신규 결정 발생 시 `docs/adr/NNNN-*.md` 로 (`/grill-with-docs` 호출). 현재 없음.

## 참고

- 루트 `PRD.md` §2.10, §2.11 (자동 스케줄 / Gmail 추출)
- 루트 `Tasks.md` Phase 5 (이 feature 의 done/deferred 작업은 거기 아카이브)
- `n8n/workflows/routinemon-auto-schedule.json`
- `lib/features/auto_schedule/` (구현 위치)

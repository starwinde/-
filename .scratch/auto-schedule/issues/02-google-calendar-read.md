# 02 — Google Calendar OAuth + 일정 읽기

Status: blocked

## 출처

Tasks.md `T5.10`.

## 설명

OAuth 토큰으로 Google Calendar API 일정 읽기. 읽은 일정을 Drift `schedules` 테이블에 매핑하여 표시.

## 작업

- [ ] OAuth 흐름 구현 (Android Native Auth via `google_sign_in` 또는 직접)
- [ ] Calendar API `events.list` 호출 (지정 기간)
- [ ] 응답 파싱 + Drift INSERT/UPDATE
- [ ] 충돌 처리 (중복 일정)

## 차단 사유

01 (Google OAuth Client ID) 미완료.

## DoD

- 실기기에서 Google Calendar 의 일정이 주간 그리드에 표시됨
- analytics: `auto_schedule_imported` 발생
- 단위/통합 테스트 통과

## Comments

(아직 없음)

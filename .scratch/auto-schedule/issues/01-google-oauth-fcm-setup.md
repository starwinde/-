# 01 — Google OAuth Client ID + Gmail/Calendar API 활성화 + (선택) FCM Server Key

Status: blocked

## 출처

Tasks.md `T5.0` (rev 9 재정의, Cloudflare/Gemini 키 제거).

## 설명

사용자 직접 수행 액션. 코드 변경 없음. 다른 이슈들의 진입 전제.

## 작업

- [ ] Google Cloud 프로젝트에서 OAuth 2.0 Client ID (Desktop/Android) 발급 — Gmail API + Google Calendar API scope 활성화
- [ ] Google Cloud Console 에서 Gmail API + Google Calendar API 활성화 (동일 프로젝트)
- [ ] (선택, T5.14 까지 지연 가능) Firebase 프로젝트 생성 + FCM Server Key 발급 (무료 티어)
- [ ] 발급한 키들을 프로젝트 루트 `.env` + n8n Credentials 에 저장 (git-ignored 확인)

## 차단 사유

`blocked` — 사용자가 직접 Google Cloud Console / Firebase Console 작업 필요. 에이전트 수행 불가.

## 근거

- PRD §2.14 개발 비용 최소화 정책 (2026-04-18 rev 9)
- Cloudflare Workers + GEMINI_API_KEY 셋업 폐기. AI 호출은 로컬 LLM via n8n.

## Comments

(아직 없음)

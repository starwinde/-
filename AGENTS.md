# AGENTS.md

이 저장소(루틴몬)에서 작업하는 모든 에이전트(Claude Code, Codex, Cursor 등)를 위한 공통 지침.

## 프로젝트 개요

루틴몬 — 보상 기반 자기관리 앱. Flutter 클라이언트 + Drift 로컬 DB + Supabase(self-hosted) + n8n + 로컬 LLM(llama-server-8600-v2 primary, LM Studio fallback).

## 빌드 / 테스트

- `flutter pub get` — 의존성 설치
- `flutter analyze` — lint (머지 조건: 0 warning)
- `flutter test` — 단위/통합 테스트
- `dart run build_runner build --delete-conflicting-outputs` — 코드 생성 (freezed, riverpod, drift)

## 비밀 / 환경변수

- `.env` (루트, git-ignored) — Supabase URL, JWT 등
- n8n Credentials — 로컬 LLM API 키 등
- 하드코딩 금지 (`rules.md` §8.2)

## 행동 규칙 / 거버넌스

이 저장소는 거버넌스 시나리오 2 (AGENTS.md + ADR + 로컬 마크다운 이슈 트래커) 로 운영. 2026-05-03 전환.

- `PRD.md` — 제품 목표, 범위, Open Decisions (단일 진실 원천 유지; feature 별 PRD 분리는 lazy)
- `Tasks.md` — 페이즈 단위 잔여 로드맵 + 완료 이력 (점진적 폐기). 새 페이즈/블록은 `.scratch/<feature>/` 로 이주
- `rules.md` — **동결됨 (pre-transition 결정 아카이브)**. 신규 결정은 `docs/adr/NNNN-*.md` 로 (`/grill-with-docs` 호출)
- `docs/adr/` — 신규 아키텍처/행동 결정 (lazy 생성)
- `.scratch/<feature>/PRD.md` + `issues/NN-*.md` — feature 단위 작업 추적 (Status: `not-started`/`in-progress`/`blocked`/`done`)

## 중요: 소리 알림

내 요청에 응답하거나 명령을 실행한 후, 소리로 알려주려면 이 명령을 실행해:

```bash
paplay /usr/share/sounds/freedesktop/stereo/complete.oga
```

> 환경: Linux (DGX Spark). macOS 의 `afplay /System/Library/Sounds/Funk.aiff` 등가물로 PulseAudio `paplay` + freedesktop `complete.oga` 사용. 이 사운드 파일은 표준 "작업 완료" 알림음.

## Agent skills

### Issue tracker

이슈는 로컬 마크다운으로 `.scratch/<feature-slug>/` 아래에 저장. **`.scratch/`는 git에 추적되어 이슈 히스토리가 보존됨**. 외부 공유 없음 (로컬 git only). See `docs/agents/issue-tracker.md`.

### Triage labels

다섯 가지 표준 트리아지 라벨을 그대로 사용 (커스텀 매핑 없음). See `docs/agents/triage-labels.md`.

### Domain docs

단일 컨텍스트 저장소. 루트 `CONTEXT.md` 와 `docs/adr/` 는 `/grill-with-docs` 가 lazy 생성 — 사전 스캐폴딩 없음. See `docs/agents/domain.md`.

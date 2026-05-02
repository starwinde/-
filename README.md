# 루틴몬 (Routinemon)

> Reward-based self-management app — 사전 등록한 집중 시간대 동안 폰 비사용을 자동 측정해 XP를 주고 픽셀 동물 펫을 키우는 자기관리 앱.

**Status**: Phase 0 — Bootstrap 완료 (2026-04-09)
**License**: MIT (앱 코드) — 수익 모델은 서버·AI·콘텐츠에 귀속
**Platform**: Android first (Flutter 3.41.6, minSdk 26, targetSdk 34)

## Architecture

- **Client**: Flutter 3.41 + Riverpod 2.x + go_router + Drift + Pigeon
- **Server**: Cloudflare Workers + Hono + Supabase JWKS (jose)
- **Data**: Supabase (Postgres + Auth + RLS) + Drift (로컬 SQLite)
- **AI**: Google Gemini Flash (자체 서버 경유, Pro 한정)

자세한 내용은 `PRD.md` / `Tasks.md` / `rules.md` 참조.

## Prerequisites

- Flutter SDK 3.41.6 stable (설치: `git clone -b stable https://github.com/flutter/flutter.git ~/flutter && export PATH=~/flutter/bin:$PATH`)
- Node.js 24 + npm
- wrangler 4.x (`npm i -g wrangler`)
- Android SDK + cmdline-tools (Android Studio 또는 수동)

## Build & Run

### Flutter client

```bash
export PATH=~/flutter/bin:$PATH
flutter pub get
dart run pigeon --input pigeons/usage_api.dart
dart run build_runner build --delete-conflicting-outputs
flutter analyze     # 0 warning 요구 (rules.md §4.1)
flutter test
flutter run -d android   # 실기기 또는 에뮬레이터
```

### Cloudflare Workers server

```bash
cd server
npm install
npx tsc --noEmit
npx wrangler dev --local --port 8787
curl http://localhost:8787/health    # {"status":"ok",...}
```

## Android Permissions (12종)

- `PACKAGE_USAGE_STATS` (Special, Settings 이동 흐름)
- `POST_NOTIFICATIONS` (필수, 거부 시 완전 차단)
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`
- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_DATA_SYNC`
- `ACTIVITY_RECOGNITION` (책상 이탈 감지)
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (사용자 동의 후)
- `QUERY_ALL_PACKAGES` (블랙리스트 후보 앱)
- `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `INTERNET`

## Environment Variables (Cloudflare Secrets — P5에서 설정)

- `GEMINI_API_KEY` — Google AI Studio에서 발급
- `SUPABASE_JWKS_URL` — Supabase project settings → JWKS URL
- `FCM_SERVER_KEY` — Firebase Console → Cloud Messaging

로컬 개발: `server/.dev.vars` (gitignore됨). 예시는 `server/.dev.vars.example` 참조.

## Phase 0 완료 항목 (2026-04-09)

- ✅ 거버넌스 4종 (PRD.md rev 0.2, Tasks.md rev 2, rules.md, REQUIREMENTS_DRAFT.md STALE)
- ✅ Flutter scaffold + Riverpod + go_router + Drift + Pigeon 통합
- ✅ AndroidManifest 권한 12종 + ForegroundService 스텁
- ✅ Cloudflare Workers + Hono + JWKS auth middleware + /health + /ai/welcome 프리셋
- ✅ flutter analyze 0 issues, tsc 0 errors, wrangler dev /health 200 ok

## 다음 단계

**Phase 1 — Native UsageStats Bridge**: Android UsageStatsManager 연동 + 권한 플로우 + BlacklistMatcher. 자세한 내용은 `Tasks.md`.

## Contribution

- 모든 변경은 `rules.md`의 Scope Guard와 Phase Discipline을 따른다.
- 새 기능은 `PRD.md §2` 또는 `§9 Open Decisions`에 등재된 범위 내에서만.
- DoD 충족 판정 시 반드시 인용 출처(명령어 + 출력) 명시.

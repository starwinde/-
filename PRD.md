# 루틴몬 (Reward-Based Self-Management App) — Product Requirements Document

## 0. Document Status

- **Owner**: starwinde
- **Last Updated**: 2026-04-09 (rev 3: §2.21 Critical alert 임계 구체화, §2.22 분석 이벤트 거버넌스 신설, Performance/Session Replay 베타 한정 도입 명시)
- **Version**: 0.3 (draft)
- **Frozen sections**: §2 Confirmed Decisions, §3 MVP Scope
- **Source of truth**: `PRD.md` (이 파일). `REQUIREMENTS_DRAFT.md`는 STALE.

---

## 1. Vision

사전 등록한 집중 시간대 동안 사용자의 휴대폰 비사용을 자동 측정해 XP를 주고, 픽셀 동물 펫(루틴몬)을 키우는 자기관리 앱. 펫은 정서적 후크고, 실질적 수익 모델은 자동 스케줄 검색 + AI 분석 리포트(Pro 전용).

**대상 사용자**: 디지털 디톡스를 원하는 한국·영어권 자기관리 사용자.

---

## 2. Confirmed Decisions

> 이 절의 항목은 변경 시 PR + 회고가 필수입니다.

### 2.1 제품
- 앱 이름: 루틴몬 (가칭, 변경 가능)
- 카테고리: 라이프스타일
- 첫 출시 버전: 1.0.0
- 라이선스: MIT 오픈소스
- 지원 언어: 한국어 + 영어 (Phase 0부터 동시)

### 2.2 플랫폼
- Flutter, Android first (iOS는 v1.x 이후)
- minSdk 26 / targetSdk 34
- 환경 분리: dev / staging / prod 3개

### 2.3 게임화
- 픽셀 동물 펫 캐릭터 육성 (3종: 새/파충/돌고래)
- 펫 사망 가능 (HP 0 또는 방치)
- 사망 후 24시간 애도 → 새 알 랜덤 부여
- 명예의 전당 (사망 펫 영구 보존, AI 마지막 멘트 포함)
- 펫도감 (실루엣 → 키운 종 해금)

### 2.4 행동 측정
- UsageStatsManager 기반 자동 추적
- 화면 켜진 횟수·시간
- 사용자 지정 블랙리스트 (추천 프리셋 + 자유 추가)
- 책상 이탈 (가속도계 10분+)
- 부정행위 방지: 서버 시간 기준

### 2.5 등급·XP·HP

```
focus_ratio = 1 − (집중 시간대 중 블랙리스트 사용 시간 / 집중 시간대 전체)
S ≥ 95% / A ≥ 85% / B ≥ 70% / C ≥ 50% / D < 50%
```

**XP**: S=30, A=20, B=10, C=3, D=0

**HP**: S=+15, A=+10, B=+5, C=0, D=-10(가중)
- HP 가중치: -10 → -15 → -20 → -25... B 등급 1회로 즉시 리셋
- HP 최대 100, overflow → XP 보너스 전환
- 추가 XP: 놀아주기 +5 (1회/일), S 5일 연속 +50

### 2.6 펫 인터랙션
- 먹이 +5 HP / 일일 1회
- 쓰다듬기 친밀도+ / 일일 3회
- 놀아주기 +5 XP / 일일 1회

### 2.7 진화 (총 13세트 PNG, ComfyUI 생성)

곡선: **후반 가속**

#### 새 5단계 (빠름, ~90일)
- 컨셉: 한국 신화·삼족오 계열 판타지 새
- 단계: 알 → 아기새 → 하늘새 → 불새 → 한새(삼족오·신성)
- XP 임계 (누적): 60 → 210 → 480 → 900

#### 파충(드래곤) 4단계 (중간, ~120일)
- 컨셉: 신화·판타지 드래곤
- 단계: 알 → 새끼 드래곤 → 작은 용 → 웅장한 드래곤
- XP 임계 (누적): 200 → 600 → 1200

#### 돌고래 4단계 (느림, ~150일)
- 컨셉: 신화·신성한 바다 생물
- 단계: 알 → 새끼 → 빛나는 돌고래 → 웅장한 제왕 돌고래
- XP 임계 (누적): 250 → 750 → 1500

### 2.8 일정·할일 (주간 기반, 2026-04-18 rev 12 개정)

> **2026-04-18 rev 12 결정**: 일일 시간 지정 수동 입력 방식 → **주간 단위 LLM wizard 기반 + 수동 추가/편집 공존**으로 전환. 사용자 명시 지시.

- **기본 단위**: 주간 (월~일). 일정은 요일·시간 구간으로 구성.
- 시간 구간 일정 + 시간 없는 to-do 둘 다.
- 카테고리: 5개 고정(업무·공부·취미·건강·기타) + 자유 태그.
- **주 생성 플로우 (기본 경로)**: `+` 버튼 → 라이프스타일 wizard (5~7 질문) → n8n 경유 로컬 LLM이 주간 일정 제안 → 사용자 편집·확인 → 일괄 적용 (이번 주 월~일의 구체 DateTime으로 bulk INSERT).
- **수동 추가**: 개별 시간 지정 입력 경로 유지 (schedule_create_page, secondary menu 또는 wizard 내부 "수동 추가" 옵션).
- **수동 편집**: 기존 schedule 항목 탭 → 편집 다이얼로그 (기존 CRUD 재사용).
- **주간 보기**: 월~일 7 column 카드 그리드 (각 column = 해당 요일의 시간순 카드 리스트). 시간 축 2D 캘린더 그리드는 v1.1+ (YAGNI).
- 입력 언어 자유.
- 휴지통: 무료 7일 / Pro 60일.
- 수정: 언제든 자유 (단 일일 정산 후 과거 일정 잠금).
- **반복 일정 (매주 자동 반복)**: v1.0 미지원. 매주 wizard 재실행으로 새 주 일정 생성. "저번 주 복사"는 Pro v1.1+.
- **기존 데이터 호환**: 기존 schedules 테이블 스키마(`startTime`/`endTime` DateTime) 유지. Drift 마이그레이션 없음. 기존 일정은 주간 뷰에서 해당 주에 그대로 표시.
- **방해 허용 (rev 22, 2026-04-25)**: 일정별 옵션 (`allow_disruption` BOOL + `disruption_intensity` INT 1/2/3, schemaVersion v3). 켜면 등록 시간 동안 적극적 기기 사용(다른 앱 활성) 감지 시 강도별 개입.
  - **L1**: 짧은 진동(200ms) + 검은 풀스크린 오버레이 5초 (Android 일반 앱 화면 OFF 강제 불가 → 오버레이 대체)
  - **L2**: 진동(500ms) + 차단 다이얼로그 + 홈 강제 이동 (Intent ACTION_MAIN/CATEGORY_HOME)
  - **L3**: 강한 진동(1000ms) + 풀스크린 차단 오버레이 + DevicePolicyManager.lockNow 30초 주기 (DEVICE_ADMIN 사용자 승인 필수, `forceStopPackage`는 시스템 전용이라 차단 오버레이 + 홈 이동으로 대체)
  - 쿨다운: 동일 일정 내 30초 1회. 단계는 누적되지 않고 사용자가 일정 등록 시 직접 선택.
  - Android 권한: VIBRATE (전 강도), BIND_DEVICE_ADMIN (L3만, 사용자 시스템 설정에서 명시 활성화).

### 2.9 집중 시간대
- 매주 전체 세팅 + 요일별 전날 미세 조정
- 수동 입력 + Google Calendar 연동 (둘 다 MVP)

### 2.10 일일 정산
- 사용자 지정 시각 (기본 04:00)
- WorkManager + AlarmManager 백그라운드 자동
- 서버 시간 기준
- 클라이언트 우선 → Supabase 백업

### 2.11 알림
- 6채널 (개별 toggle, 기본 모두 ON): 일정 / 방해 / 정산 / 주간 / 진화 / 이탈
- 기본 DND 22:00–07:00 + 사용자 수정
- FCM 서버 푸시 (자체 서버에서)
- 시스템 권한 차단 시 완전 차단

### 2.12 데이터·동기화
- 로컬 우선 (Drift) + Supabase 백업
- 5분 간격 outbox 동기화
- LWW 충돌 해결
- 멀티 디바이스 동시 사용 자유
- 데이터 내보내기: JSON + CSV (무료 월 1회 / Pro 무제한)
- 계정 탈퇴 30일 후 완전 삭제
- raw UsageStats 클라우드 전송 금지 (집계만)

### 2.13 인증
- Supabase Auth + Google 로그인 (선택, 2026-05-04 rev 27 결정 — 旧 "강제, 첫 화면"에서 게스트 모드 허용으로 전환)
  - 온보딩 step 2 에서 "Google로 로그인" 또는 "나중에 로그인" 선택 가능
  - 게스트 모드(미인증)는 로컬 Drift 저장소만 사용하며 Supabase 동기화·멀티 디바이스 동기화·자동 일정 가져오기(Calendar/Gmail)는 비활성. 설정 화면에서 언제든 사후 로그인하여 동기화 활성 가능
  - PRD §2.16 자동 스케줄(Pro/Calendar/Gmail) 기능은 인증 필수 → 게스트 모드에서는 진입점 비활성화
- Apple은 v1.x 이후
- 자체 서버 인증: Supabase JWT 전달 + JWKS 검증 (인증 사용자에 한함)
- 닉네임 2–12자 / 펫 별명 1–10자 (둘 다 필수, 검열·제한)
- 변경 빈도: 닉네임 월 1회 / 펫 별명 주 1회 (Supabase 권위 — 게스트 모드에서는 로컬 권위)

### 2.14 자체 서버 (n8n self-hosted + 로컬 LLM)

> **2026-04-18 rev 9 결정**: Cloudflare Workers 의존 전면 제거. 개발 비용 최소화 원칙에 따라 **n8n self-hosted + 로컬 LLM**을 단일 기본 스택으로 확정. 구 `server/` 디렉토리는 `server.archived/`로 보존. Cloudflare 재도입은 Phase 7 이후 트래픽 실측 결과에 따라 재평가한다.

- **런타임**: n8n self-hosted (https://localhost:5678, HTTPS). 워크플로우가 API 로직을 대체.
- **API 책임**:
  - AI 호출 라우팅 (→ 로컬 LLM, §2.15 참조)
  - PDF·이미지 카드 생성 (n8n code node 또는 클라이언트 측 생성으로 재평가 — T5.3/T5.4 구현 시 결정)
  - FCM 푸시 (n8n HTTP Request 노드 → Firebase FCM REST API)
  - AI 콘텐츠 검사 레이어 (욕설·자해 차단)
- **환경변수/비밀 관리**: `.env` (루트, git-ignored) + n8n Credentials. Cloudflare Secrets 의존 제거. 프로덕션 배포 시에만 별도 비밀 저장소 재평가.
- **dev/staging/prod**: 현재는 단일 self-hosted 인스턴스만 운영. 분리는 베타(Phase 6) 이후 재평가.
- **로컬 데이터 권위**: 클라이언트 우선.
- **개발 비용 정책**: v1.0까지 유료 cloud 서비스(Cloudflare Workers/Gemini API 등) 도입 금지. 필수 유료 서비스는 Supabase(현재 self-hosted Docker) + RevenueCat + Firebase FCM(무료 티어)만 허용.

### 2.15 AI 코치 (Pro 전용)
- **AI 제공자: 로컬 LLM via n8n** (2026-04-18 rev 9 결정 — Gemini Flash에서 전환)
  - Primary: `llama-server-8600-v2` (http://localhost:8600, OpenAI 호환, 모델 `gemma-4-E2B-it-Q4_K_M`)
  - Secondary/fallback: LM Studio (http://localhost:1234, 모델 `gemma-4-26b-a4b` 등)
  - 호출 경로: Flutter → n8n webhook → llama-server (자체 서버 경유 규칙 준수, rules.md §9.1)
- 무료: 수치/차트 리포트만
- Pro: 주간 + 월간 자동 + AI 일정 추천 패턴 학습 개선
- 입력: JSON + 자연어 하이브리드, 익명화
- 출력: 사용자 설정 언어
- 호출 실패 시 3회 재시도 → 폴백 수치 리포트
- 출력 형식: 인앱 텍스트(스크롤·카드) + 이미지 카드(소셜) + PDF(월/년)
- 첫 펫 인사: 로컬 LLM + 5개 템플릿 프리셋 (알 부화 애니메이션 중 동기 호출)

#### 2.15.1 비용 통제 정책 (2026-04-18 갱신 — 로컬 LLM 전환)

| 항목 | 정책 |
|---|---|
| **무료 사용자 호출** | 0건 (모든 AI 호출은 Pro 한정, NFR-09 강제) |
| **Pro 사용자 호출 빈도** | 주간 리포트 1회/주, 월간 리포트 1회/월, AI 일정 추천 5회/주, 첫 펫 인사 1회 (계정 생성 시) |
| **모델** | `gemma-4-E2B-it-Q4_K_M` (llama-server-8600-v2, 로컬, 호출당 0원) |
| **요청당 토큰 cap** | input ≤ 4K, output ≤ 1.5K (n8n 워크플로우 레벨에서 강제) |
| **Pro 1인 월 예산 상한** | 호출당 비용 0원이므로 월 비용 자체는 제거. 대신 **단일 사용자 동시 호출 ≤ 2**, **전체 큐 대기 ≤ 30초** 기준으로 rate limit (로컬 GPU throughput 보호) |
| **캐시 정책** | 동일 입력 해시 → 24h TTL n8n 캐시 또는 Drift (주간 리포트는 토요일 자정 일괄 생성 + 캐시) |
| **첫 펫 인사 폴백** | 5개 한국어 + 5개 영어 템플릿 프리셋 (LLM 실패/타임아웃 시 즉시 사용) |
| **리포트 폴백** | 3회 재시도 → 클라이언트 측 수치 기반 폴백 리포트 (LLM 호출 없이 차트/숫자만) |
| **모니터링** | n8n 워크플로우에서 user_id별 일일/월간 호출 카운터 → 한도 초과 시 폴백 강제 |
| **글로벌 처리량 가드** | 단일 서버 기반 → 일일 총 호출 상한은 로컬 GPU capacity에 따라 조정 (초기 가설 1000 calls/day, 실측 후 PRD §7 NFR로 확정). 초과 시 모든 사용자 폴백, Discord Critical 알림 |

### 2.16 자동 스케줄 검색 (Pro 핵심)
- Google Calendar / Outlook (OAuth)
- Gmail 일정 키워드 추출 (Gmail API + **로컬 LLM NLP via n8n**, 2026-04-18 갱신)
- 카톡/슬랙: Share intent로 대체 (Accessibility 사용 X)
- 사용 패턴 기반 추천

### 2.17 수익화 (v1.1+ 이월, 2026-04-19 rev 18 결정)

> **v1.0 스코프 제외**: 2026-04-19 사용자 결정으로 **결제·체험·Lite 강등 관련 전 기능은 v1.1+로 이월**. v1.0은 **기능 구현 중심**. T5.5/T5.6/T5.7 태스크는 DEFERRED. Pro 게이팅 조건이 있던 기능(T5.17 데이터 내보내기 월 1회, AI 리포트 Pro 한정 등)은 v1.0에서 **전 사용자 무제한**으로 운영하되, v1.1 수익화 도입 시 restore.

v1.1+ 계획 (참고):
- 월 2,900원 / 연 24,900원
- Play Store 자동 환산 (KRW 기준, 글로벌)
- RevenueCat 영수증 검증
- 무료 15일 체험 (첫 7일 권한 면제 + 8일 권한 필수) → Lite 자동 강등
- 환불 후 결제 기간 끝까지 Pro 유지
- 결제 실패 → Google Play 유예 3일 + 경고 배너
- 광고 없음

### 2.18 시스템 통합
- 홈 위젯 2×2·4×2 (30분 갱신 + 이벤트 트리거, 2026-04-25 rev 21에서 1×1 제외 결정)
- SNS 공유: 카카오톡 + Instagram 스토리
- 이미지 카드 워터마크 (링크 없음)

### 2.19 mood 체크인
- 일일 1~5 이모지
- 게임 영향 없음 (AI 입력용)
- 누락 시 중립값(3) 자동

### 2.20 UI / UX
- 메인 컬러: 파스텔 그린
- 다크모드: 시스템 + 수동 오버라이드
- 픽셀 폰트: DungGeunMo (OFL)
- 사운드: 주요 이벤트(레벨업·진화·부화)에 짧은 사운드
- 햅틱: 탭·레벨업
- 홈 화면: 대시보드 (펫 + 일정 + 통계)

### 2.21 출시·운영
- 단일 개발자, 45일 스프린트 (Claude 멀티 에이전트 가속)
- Closed Beta 5–10명 (가족·친구) → 1주 버그픽스 + 1주 내부 검증 → 출시
- 베타 피드백: 원격측정만 (Sentry/PostHog/Firebase Analytics)
- 핫픽스 정책: 클라이언트 포스 + 서버 즉시 키리스 + Remote Config
- 업데이트 주기: 비정기
- 출시 후 2주 최소 필수 운영만
- 운영 모니터링: n8n execution logs + Sentry → Discord webhook (Critical만)

#### 2.21.1 분석/원격측정 Stack (3개 유지, 2026-04-09 결정)

| Tool | 역할 | 상시 ON | 비고 |
|---|---|---|---|
| **Sentry** | 크래쉬·에러 보고, performance trace | ✅ 항상 | crash-free user rate KPI 측정 |
| **PostHog** | Product analytics, funnel, cohort, feature flag | ✅ 항상 | 핵심 KPI 5개 측정 |
| **PostHog Session Replay** | 사용자 행동 영상 재현 | ⚠️ 베타만 (Phase 6) | v1.0 출시 시 OFF, Remote Config 토글 |
| **Firebase Analytics** | 일반 분석, Google ecosystem 통합 | ✅ 항상 | PostHog와 일부 중복 인지 |
| **Firebase Performance Monitoring** | NFR-03(콜드 스타트 <2s) / NFR-04(배터리 <5%/day) 실측 | ⚠️ 베타만 (Phase 6) | v1.0 출시 시 OFF |

#### 2.21.2 Discord Critical Alert 임계 (구체)

다음 조건 충족 시 자체 서버에서 Discord webhook으로 즉시 알림:

| # | 조건 | 트리거 윈도우 | 출처 |
|---|---|---|---|
| C-1 | Sentry error_rate > 1% | 5분 | Sentry alert rule |
| C-2 | n8n `/webhook/routinemon/health` 5xx 응답 > 3건/min | 1분 | n8n execution log + 외부 prober |
| C-3 | 로컬 LLM 처리량 포화 (큐 대기 > 30s 지속) | 5분 | n8n 워크플로우 카운터 (PRD §2.15.1 연동) |
| C-4 | 일일 글로벌 AI 호출 > 1000 calls | 일일 누적 | PRD §2.15.1 글로벌 가드 트리거 |
| C-5 | n8n 서버 down / 워크플로우 실패 연속 > 5회 | 즉시 | n8n execution log |
| C-6 | Supabase RLS 정책 위반 시도 | 즉시 (5건/min 이상) | Supabase audit log |
| C-7 | crash-free user rate < 99% | 1시간 | Sentry KPI |

**Discord webhook payload 형식**:
```json
{
  "alert_id": "C-1",
  "severity": "critical",
  "title": "Sentry error_rate > 1%",
  "message": "<에러 요약>",
  "timestamp": "<ISO8601>",
  "link": "<Sentry/n8n 대시보드 URL>"
}
```

임계값 calibration: 베타 트래픽 데이터를 보고 v1.1에서 조정.

### 2.22 분석 이벤트 거버넌스 (2026-04-09 신설)

#### 2.22.1 Spec 위치
- **단일 source of truth**: `docs/analytics_events.md` (Phase 1 진입 시 골격 생성)
- 모든 PostHog/Firebase Analytics 이벤트는 이 파일에 사전 정의되어야 한다 (코드보다 spec 우선)
- 이벤트 추가는 PR 변경 + 페이즈 retrospective에 인용

#### 2.22.2 작성 방식 — 페이즈별 incremental

각 페이즈에서 새 기능을 만들 때 해당 페이즈 이벤트를 `docs/analytics_events.md`에 추가한다. 페이즈 종료 DoD에 "analytics_events.md 해당 페이즈 이벤트 추가" 항목 강제.

| Phase | 추가할 이벤트 (예시 — 실제 작성은 해당 페이즈에서) |
|---|---|
| 1 | `usage_permission_requested`, `usage_permission_granted`, `usage_permission_denied`, `blacklist_app_added` |
| 2 | `signup_started`, `signup_completed`, `onboarding_step_<1~5>`, `egg_chosen`, `egg_hatched`, `pet_named`, `schedule_created`, `task_created` |
| 3 | `focus_session_started`, `focus_session_ended`, `daily_score_recorded`, `pet_evolved`, `hp_critical`, `pet_died` |
| 4 | `pet_interaction_<feed/pet/play>`, `pet_dex_unlocked`, `hall_of_fame_viewed` |
| 5 | `paywall_viewed`, `purchase_initiated`, `purchase_completed`, `purchase_failed`, `trial_started`, `trial_expired`, `lite_demoted`, `weekly_report_viewed`, `widget_added`, `auto_schedule_imported`, `share_intent_processed` |
| 6 | `beta_tester_invited`, `beta_session`, `feedback_submitted` |

#### 2.22.3 이벤트 스키마

각 이벤트는 다음 필수 필드를 가진다:

```yaml
event_name: focus_session_started
trigger: 사용자가 집중 세션 시작 버튼 탭 또는 일정 시작 시각 도달
properties:
  - session_id: string (uuid)
  - planned_duration_min: int
  - schedule_id: string (nullable)
  - source: enum [manual, scheduled, calendar]
kpi_mapping:
  - 주간 평균 세션 수 (PRD §8)
  - focus_ratio 계산 입력
phase: 3
sdks: [posthog, firebase_analytics]
```

#### 2.22.4 User Properties (Phase 1 진입 시 정의)

PostHog/Firebase identify 호출 시 다음 속성 전달:

| Property | 타입 | 값 |
|---|---|---|
| `plan` | enum | `free`, `trial`, `pro`, `lite` |
| `locale` | string | `ko`, `en` |
| `pet_species` | enum | `bird`, `dragon`, `dolphin`, `none` |
| `current_pet_level` | int | 0~5 |
| `signup_date` | ISO8601 | |
| `total_pets_died` | int | 명예의 전당 카운트 |
| `subscription_started_at` | ISO8601 (nullable) | |
| `app_version` | string | |
| `android_sdk_int` | int | |

#### 2.22.5 KPI ↔ 이벤트 매핑 (PRD §8와 1:1)

| KPI (§8) | 측정 이벤트 | 계산 방식 |
|---|---|---|
| D7 retention ≥ 30% | `app_open` | signup 후 7일째에 `app_open` 발생한 유저 / 7일 전 signup 유저 |
| 주간 평균 세션 수 ≥ 5 | `focus_session_started` | 주간 합계 / 활성 유저 |
| 평균 focus ratio ≥ 70% | `daily_score_recorded.focus_ratio` | 일일 평균 |
| 무료 → Pro 전환율 ≥ 5% | `paywall_viewed` → `purchase_completed` | 퍼널 |
| Crash-free user rate ≥ 99% | Sentry 자동 | Sentry KPI |

#### 2.22.6 핵심 퍼널 정의

| Funnel | 단계 |
|---|---|
| **온보딩 5단계** | `signup_started` → `signup_completed` → `onboarding_step_1` → `_2` → `_3` → `_4` → `_5` → `egg_hatched` → `pet_named` |
| **결제 3단계** | `paywall_viewed` → `purchase_initiated` → `purchase_completed` |
| **첫 집중 세션** | `pet_named` → `schedule_created` → `focus_session_started` → `focus_session_ended` |
| **펫 진화** | `focus_session_ended` (XP 누적) → `pet_evolved` |

---

## 3. MVP Scope

### 3.1 In

- 5단계 온보딩 (소개·로그인·권한·집중시간·알 부화)
- AI 첫 일정 제안 + AI 펫 인사 (로컬 LLM via n8n, §2.15 참조)
- 수동 일정 + Google Calendar 연동 + 카테고리/태그
- UsageStats 기반 focus_ratio·등급·XP·HP
- 펫 시스템 (3종, 13세트 아트, 진화, 사망, 명예의 전당, 펫도감)
- 펫 인터랙션 (먹이·쓰다듬·놀아주기)
- 일일 정산 (사용자 지정 시각, 백그라운드 자동)
- 6채널 알림 + DND
- AI 주간/월간 리포트 (Pro)
- PDF 다운로드 + 이미지 카드 + SNS 공유 (Pro 일부)
- 자동 스케줄 검색 (Calendar/Gmail/Share intent/패턴) (Pro)
- 무료 15일 체험 + 결제 (RevenueCat)
- 클라우드 동기화 (5분 간격, LWW)
- 데이터 내보내기 (JSON+CSV)
- 홈 위젯 2종 (2×2, 4×2 — rev 21)
- 다크모드
- 한국어/영어 i18n
- 명예의 전당 + 펫도감
- mood 체크인
- 책상 이탈 감지

### 3.2 Out (defer to v1.1+)

- iOS
- 친구·소셜·리더보드
- Apple 로그인
- Accessibility Service 기반 실시간 차단
- 다중 펫 동시 사육
- 사용자 맞춤 펫 (AI 생성)
- 위젯 디자인 확장
- Apple Watch / Wear OS
- **AR 기반 집중 세션** (물리적 공간 인식 + 집중 시간 트래킹 연동)

---

## 4. User Personas

- **P1 — 디지털 디톡스가 필요한 직장인/대학생**: 집중 시간 보호가 핵심
- **P2 — 게임화 보상으로 동기부여 필요한 사용자**: 펫 육성·진화에 강한 애착
- **P3 — AI 코치의 패턴 분석을 원하는 자기관리 매니악**: Pro 구독 우선

---

## 5. Core User Journeys

- **J1**: 첫 실행 → 5단계 온보딩 → 알 선택 → AI 인사 → 첫 세션
- **J2**: 매일 → 일정 진행 → 자동 정산 → 등급·XP·HP 반영 → 펫 진화
- **J3**: 주말 → AI 주간 리포트 (Pro) → 패턴 인사이트 → 다음 주 일정 조정
- **J4**: 펫 사망 → 명예의 전당 → 24시간 애도 → 새 알 부여 → 새 시작
- **J5**: 무료 15일 체험 → Lite 자동 강등 → 가치 인식 → Pro 결제

---

## 6. Functional Requirements (FR)

- FR-01 사용자는 시간 구간 일정과 시간 없는 할일을 등록할 수 있다
- FR-02 시스템은 일정 시작 5분 전 알림을 보낸다
- FR-03 시스템은 집중 시간대 동안 UsageStats를 수집한다
- FR-04 시스템은 사용자 지정 시각에 일일 정산을 백그라운드 자동 수행한다
- FR-05 시스템은 focus_ratio를 계산해 S/A/B/C/D 등급을 부여한다
- FR-06 시스템은 등급에 따라 XP와 HP를 변동한다
- FR-07 시스템은 XP 임계 도달 시 펫을 진화시킨다
- FR-08 시스템은 HP 0 또는 방치 시 펫을 사망시키고 명예의 전당에 등재한다
- FR-09 사용자는 펫에게 먹이·쓰다듬·놀아주기를 줄 수 있다 (일일 한도)
- FR-10 사용자는 블랙리스트 앱을 추가/제거할 수 있다
- FR-11 시스템은 블랙리스트 앱 열림 시 단계별 경고를 보낸다
- FR-12 시스템은 책상 이탈을 감지해 경고하고 HP를 감소한다
- FR-13 사용자는 mood 체크인을 일일 1회 입력할 수 있다 (선택)
- FR-14 시스템은 5분마다 outbox를 Supabase로 동기화한다
- FR-15 시스템은 멀티 디바이스 동기화 충돌을 LWW로 해결한다
- FR-16 사용자는 데이터를 JSON/CSV로 내보낼 수 있다 (무료 월 1회 / Pro 무제한)
- FR-17 시스템은 Pro 사용자에게 주간·월간 AI 리포트를 자동 생성한다
- FR-18 시스템은 PDF 리포트와 이미지 카드를 자체 서버에서 생성한다
- FR-19 사용자는 카카오톡·Instagram 스토리에 결과를 공유할 수 있다
- FR-20 사용자는 Pro 구독을 결제·취소·환불할 수 있다 (RevenueCat)
- FR-21 사용자는 일정별 "방해 허용"을 켜고 강도(L1/L2/L3)를 선택할 수 있다. 시스템은 등록 시간 동안 적극적 기기 사용 감지 시 선택한 강도로 개입한다 (rev 22, T5.21). L3은 DEVICE_ADMIN 활성화 필수.

---

## 7. Non-Functional Requirements (NFR)

- NFR-01 권한 거부 시에도 앱은 크래시하지 않는다 (단, UsageStats 권한은 첫 7일 면제 후 필수)
- NFR-02 오프라인에서 모든 핵심 기능이 동작한다 (정산·진화·인터랙션)
- NFR-03 콜드 스타트 < 2초 (mid-tier 기기)
- NFR-04 배터리 영향 < 5%/day
- NFR-05 한국어/영어 동시 지원
- NFR-06 raw UsageStats 데이터는 클라우드에 전송되지 않는다 (집계만)
- NFR-07 사용자 데이터는 PIPA·GDPR을 준수한다
- NFR-08 자체 서버 응답 < 1초 (P95)
- NFR-09 AI 호출 비용은 Pro 사용자만 발생한다
- NFR-10 시간 조작 부정행위는 서버 시간 기준으로 차단된다

---

## 8. Success Metrics (post-MVP)

- D7 retention ≥ 30%
- 주간 평균 세션 수 ≥ 5
- 평균 focus ratio ≥ 70%
- 무료 → Pro 전환율 ≥ 5%
- Crash-free user rate ≥ 99%

---

## 9. Open Decisions (OD)

- OD-1 ~~광고 정책~~ → ✅ Decided: 광고 없음
- OD-2 dev 모드(테스트 데이터 주입) — 구현 단계에서 결정
- OD-3 푸시 알림 deep link 매핑 — Phase 5·6
- OD-4 멀티 디바이스 동기화 충돌 사용자 알림 — Phase 6
- OD-5 사용자 부재 시 FOMO 알림 정책 — Phase 5·6
- OD-6 펫 사망 후 기존 일정·블랙리스트·집중시간대 처리 — Phase 4·5
- OD-7 Closed Beta 참여자 인센티브 — Phase 6
- OD-8 ComfyUI 실행 책임 (수동 vs 자동 vs 백엔드) — Phase 4 시작 시
- OD-9 HP·XP 공식 미세 튜닝 — Phase 3 테스트 후
- OD-10 ~~로그인 강제 vs 게스트 모드~~ → ✅ Decided 2026-05-04: 게스트 모드 허용 (PRD §2.13 개정). 사유: 실기기 검증 중 "나중에 로그인" 스킵 후 redirect 가드(app.dart)에 의해 온보딩 첫 화면으로 튕기는 버그 발생. PRD "로그인 강제"와 onboarding "나중에 로그인" 버튼이 모순되어 발생. 사용자 선택지(B 게스트 모드 허용) 채택.

---

## 10. Glossary

- **focus ratio**: 1 − (집중 시간대 중 블랙리스트 사용 시간 / 집중 시간대 길이)
- **등급**: focus ratio 기반 S/A/B/C/D
- **HP 가중치**: 연속 차감 시 5씩 증가하는 페널티 (-10 → -15 → -20...)
- **루틴몬**: 사용자가 키우는 픽셀 동물 펫
- **명예의 전당**: 사망한 펫의 영구 기록 보관소
- **펫도감**: 모든 종·진화 단계 컬렉션 (실루엣 → 해금)
- **outbox**: Drift에서 Supabase로 동기화 대기 중인 변경사항 큐
- **LWW**: Last-Write-Wins, 충돌 해결 정책
- **Lite**: 무료 사용자 모드 (15일 체험 후)
- **Pro**: 유료 구독 사용자 모드
- **DoD**: Definition of Done, 페이즈/태스크 완료 조건

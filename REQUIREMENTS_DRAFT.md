# 루틴몬 (Reward-Based Self-Management App) — 요구사항 수집 중간 저장본

> ## ⚠️ STALE — 2026-04-09에 PRD.md / Tasks.md / rules.md로 통합 완료
>
> 이 파일은 2026-04-08 작성된 35라운드 요구사항 수집 중간 저장본입니다. **14개 미결정 사항 중 13개는 이미 PRD.md에 반영**되었고, 남은 1개(AI 비용 한도)도 PRD §2.15에 수치로 고정되었습니다.
>
> **현재 source of truth**: `PRD.md`, `Tasks.md`, `rules.md`
> **이 파일은 역사적 기록**으로만 보존합니다.

## Document Status
- **작성일**: 2026-04-08
- **단계**: 요구사항 수집 (Plan Workflow Phase 1) — **미완성 / 중간 저장**
- **다음 세션**: 남은 14개 결정사항 추가 수집 → PRD/Tasks/rules 초안 작성 → 사용자 승인 → 부트스트랩
- **이 파일은 코드 구현 시작 승인이 아닙니다.** 다음 세션에서 추가 질문 후 정식 PRD를 작성합니다.

> 이 파일은 `~/.claude/plans/polished-toasting-hejlsberg.md`의 사본입니다. 다음 세션에서 컨텍스트 복원에 사용됩니다.

---

## Context (왜 이 앱인가)

빈 디렉토리 `/home/str_dgx_spark/Desktop/Reward-Based-Self-Management-AppReward-Based-Self-Management-App/`에서 시작하는 신규 모바일 앱.

**제품 비전**: 사전에 등록한 집중 시간대 동안 사용자의 휴대폰 비사용을 자동 측정해 XP를 주고, 픽셀 동물 펫(루틴몬)을 키우는 자기관리 앱. 펫은 정서적 후크고, 실질적 수익 모델은 **자동 스케줄 검색 + 상세 분석 리포트**(Pro).

**대화 진행 상황**: 약 35 라운드(약 130개 결정 항목) 수집 완료.

---

## A. 제품 정체성

| 항목 | 결정 |
|---|---|
| 앱 이름 | **루틴몬** (가칭, 변경 가능) |
| 카테고리 | 라이프스타일 |
| 타겟 사용자 | 디지털 디톡스를 원하는 한국어/영어 사용자 |
| 지원 언어 | 한국어 + 영어 (Phase 0부터 동시 작성) |
| 라이선스 | **MIT 오픈소스** (수익 모델은 별도 — 가치는 서버·AI·콘텐츠에 귀속) |

---

## B. 플랫폼 / 기술 스택

| 영역 | 결정 |
|---|---|
| 프레임워크 | **Flutter** (cross-platform), **Android first** |
| iOS | 미정, v1.x 이후 (Screen Time API 제약 큼) |
| State | Riverpod 2.x (`@riverpod` 코드 생성) |
| Routing | go_router 14.x |
| Local DB | **Drift** (SQLite, 단일 source of truth) |
| Native bridge | **Pigeon** (Dart ↔ Kotlin), 수기 MethodChannel 금지 |
| Cloud backend | **Supabase** (Postgres + Auth + Storage + RLS) |
| 자체 API 서버 | **Node.js + Hono on Cloudflare Workers** (AI 프록시·PDF·이미지 카드·푸시) |
| AI 모델 | **Google Gemini Flash** (자체 서버 경유) |
| 결제 백엔드 | **Google Play Billing + RevenueCat** |
| 푸시 | **FCM** (자체 서버에서 발송) |
| 알림 | flutter_local_notifications + Foreground Service |
| 원격측정 | Sentry(크래쉬) + PostHog/Mixpanel(제품 분석) + Firebase Analytics |
| 모니터링 | Cloudflare 기본 + Sentry 알림 (자체 호스팅, 추후 SaaS 고려) |
| min/target SDK | minSdk 26 / targetSdk 34 |
| 암호화 수준 | 업계 표준 (전송 HTTPS, RLS, 로컬 평문) |

---

## C. Android 권한 (온보딩 권한 탭에서 일괄 청구)

- `PACKAGE_USAGE_STATS` (Special permission, Settings 이동 흐름)
- `POST_NOTIFICATIONS` (Android 13+) — 거부 시 완전 차단
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`
- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_DATA_SYNC`
- `ACTIVITY_RECOGNITION` (책상 이탈 감지)
- `BATTERY_OPTIMIZATION` exemption (안내)
- `QUERY_ALL_PACKAGES` (블랙리스트 후보 앱 목록)
- `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `INTERNET`

---

## D. 사용자 / 인증

| 항목 | 결정 |
|---|---|
| 온보딩 흐름 | **5단계**: 소개 → 로그인 → 권한 → 집중시간 설정 → 알 부화 |
| 로그인 | **강제 로그인** (첫 화면), **Google + Apple** (Supabase Auth) |
| 닉네임·펫 별명 | 둘 다 필수 입력 |
| 이름 변경 빈도 | 닉네임 월 1회 / 펫 별명 주 1회 |
| 욕설 검열 | 기본 금칙어 리스트 (한+영) |

---

## E. 온보딩 추가 수집 (전부 선택·건너뛰기 가능)

- **앱 설치 이유**: 5개 목적 카드 다중 선택 (예: 수험·자격증·장기 프로젝트·일공부 병행·디지털 디톡스)
- **직업·연령대**
- **안정적 기상·취침 시간**
- **시도해본 다른 자기관리 앱 경험**

→ 이 모든 항목이 AI 첫 일정 제안의 입력으로 사용됨.

---

## F. 첫 사용자 경험 (콜드 스타트)

| 단계 | 설계 |
|---|---|
| 알 선택 | 3종 알(새·파충·돌고래) 모양 제시 → 사용자가 직접 선택 |
| 알 부화 | 온보딩 완료 즉시 (5단계 연출: 알 → 금 → 틀어짐 → 펫 등장 → 이름 입력) |
| 첫 일정 | **AI(Gemini)가 온보딩 답변을 입력으로 받아 의사 일정·집중 시간대를 자동 작성**, 사용자가 검토·수정·수락 |
| 첫 하루 (데이터 0) | 정직한 대시보드 ("오늘 함께 시작!") + AI 제안 일정이 미리 채워져 있음 |
| 컴플리먼터리 기간 | **첫 7일은 권한 없이도 체험 가능** → 8일째부터 권한 필수, 총 15일 Pro 체험 |
| 튜토리얼 | 첫 화면 코치마크 팁 단계별 안내 (재재생 가능) |

---

## G. 핵심 게임 시스템

### G.1 집중 시간대
- **매주 전체 세팅 + 요일별 전날 미세 조정**
- 등록 형태: 수동 입력 + Google Calendar 연동 (둘 다 MVP 포함)

### G.2 일정·할일
- **시간 구간 일정** + **시간 없는 할일(to-do)** 둘 다 지원
- 카테고리: 5개 고정 (업무·공부·취미·건강·기타) — *다음 세션에서 재확인*
- 입력 언어: 자유 (UI 언어와 무관)
- 삭제 복구: **무료 7일 휴지통 / Pro 60일**

### G.3 등급 (focus ratio 단일 지표)
```
focus_ratio = 1 − (집중 시간대 중 블랙리스트 사용 시간 / 집중 시간대 전체)
S ≥ 95% / A ≥ 85% / B ≥ 70% / C ≥ 50% / D < 50%
```

### G.4 XP / 레벨
- 일일 등급 → XP 환산 → 펫 레벨 누적
- 진화 임계: **종별 다른 곡선** (새 빠름·파충 느림·돌고래 중간), 우선 XP 기반만, 추후 다른 조건 추가
- 진화 트리거: **매일 일일 정산 시 체크**

### G.5 HP (하드코어)
- 시작 100, 첫 차감 -10, 연속 차감 시 5씩 가중 (-10, -15, -20, -25, ...)
- **회복**: 일일 세트 달성도 기준 등급 보상
- **사망 조건**: HP 0 또는 방치 일수 (혼합)
- **책상 이탈** (가속도계 + 10분+ 지속 움직임): 이탈 경고 알림 + 소량 HP 감소
- **할일 미완료**: HP 패널티

### G.6 펫 사망·재시작
- 사망 후 **24시간 애도 기간** → 새 알
- 새 알: **랜덤 부여** (선택 불가, 첫 알 흐름과 차이)
- **명예의 전당**: 이름·종·최고 레벨·생존 일수·생전 평균 focus ratio·총 XP·사망 원인·마지막 멘트(AI 생성)

### G.7 펫 인터랙션 (홈·펫 탭 둘 다)
| 액션 | 효과 | 일일 한도 |
|---|---|---|
| 먹이 | +5HP 고정 | 1회 |
| 쓰다듬기 | 친밀도/기분+ | 3회 |
| 놀아주기 | XP+ | 1회 |

먹이 = +5HP 고정으로 가중치 차감 모델과 공존 (생존 메커니즘 유지).

### G.8 펫도감
- **실루엣만 공개**, 이름·설명은 키운 종만 해금
- 위치: 펫 탭 안 서브 메뉴

### G.9 진화 단계 / 연출
- **새 5단계 / 파충 4단계 / 돌고래 4단계** = 총 13세트 일러스트
- 단계당 독립 일러스트 (재활용 X)
- 단계 변경 시: 축하 애니메이션 2~3초 + 새 일러스트

---

## H. 행동 감지 신호

- 앱 사용 시간 (UsageStatsManager)
- 화면 켜진 횟수·시간
- 사용자 지정 블랙리스트 (**추천 프리셋 + 자유 추가**)
- 책상 이탈 (가속도계 10분+ 지속적 움직임)
- **블랙리스트 앱 열었을 때 개입**: 단계별 상승 (1회 부드러운 알림 → 3회 팝업 → 5회 전체화면 경고)

---

## I. mood 체크인

- 일일 기분 1~5 이모지 (하루 끝)
- **게임 영향 없음** (AI 리포트 입력용 기록만)
- **누락 시 처리**: 중립값(3) 자동 입력

---

## J. 알림 / 푸시

- **채널 6개 (개별 toggle)**:
  1. 일정 알림
  2. 방해 경고 (블랙리스트 앱 열림)
  3. 일일 정산
  4. 주간 리포트
  5. 진화 알림
  6. 책상 이탈 경고
- **DND**: 기본 22:00–07:00 차단 + 사용자 수정 가능
- **푸시 발송**: FCM 서버 푸시 (자체 서버에서 발송)
- **시간대**: 디바이스 자동 감지, 매 로그인 시 서버에 리포트
- **HP 위기 알림**: 알림 최소화 (앱 아이콘 배지만)
- **시스템 알림 권한 차단 시**: **완전 차단** (권한 필수)

---

## K. 일일 정산

| 항목 | 결정 |
|---|---|
| 시각 | **사용자 지정 '하루 끝 시각'** (기본 04:00) |
| 트리거 | WorkManager + AlarmManager 백그라운드 자동 |
| 시간 기준 | **서버 시간** (부정행위 방지) |
| 수행 | 점수 확정 → HP 변동 → 진화 체크 → AI 리포트 입력용 집계 → FCM 푸시 발송 |

---

## L. AI 코치 / 리포트

| 항목 | 결정 |
|---|---|
| 모델 | **Gemini Flash** (자체 서버 경유) |
| 무료 | **주간 리포트만** 자동 생성 |
| Pro | 주간 + 월간 자동, AI 일정 추천 패턴 학습 개선 |
| 호출 실패 | 3회 재시도 후 **수치 기반 폴백 리포트** |
| 입력 형식 | **JSON 구조 + 주요 이벤트 자연어 하이브리드** |
| 출력 언어 | 사용자 설정 언어로 직접 요청 |
| 익명화 | 서술 필드 제거, 패키지명 해시, 조 결과만 |
| 출력 형식 | 인앱 텍스트(스크롤·카드) + 이미지 카드(소셜) + PDF(월/년) |
| 톤 | AI 코치 스타일 멘토링 |
| 카드 디자인 | 파스텔·귀여운 펫 일러스트 주인공 |
| 이미지·PDF 생성 | **자체 서버** (Cloudflare Workers + 템플릿) |

---

## M. 자동 스케줄 검색 (Pro 핵심 가치)

- **Google Calendar / Outlook 일정 읽기** (OAuth)
- **Gmail/메일 일정 키워드 추출** (Gmail API + Gemini NLP)
- **카톡/슬랙**: **공유 시트(Share intent)로 대체** (Accessibility Service 미사용 → Play Store 정책 회피)
- **사용 관습 패턴 기반 추천**

---

## N. 데이터 / 클라우드

| 항목 | 결정 |
|---|---|
| 저장 정책 | 로컬 우선 (Drift) + 클라우드 백업 (Supabase) |
| 백업 빈도 | **5분 간격 주기적 동기화** (outbox 패턴) |
| 충돌 해결 | **Last-Write-Wins** (시각 기준) |
| Lite 백업 | **Lite도 클라우드 백업 제공** |
| 데이터 내보내기 | **JSON + CSV** (상시 제공) |
| 계정 탈퇴 | 30일 후 완전 삭제 |
| raw UsageStats | **클라우드 전송 금지** (집계만) |
| DB 마이그레이션 | 버전별 명시적 + 자동 백업 |
| 시간대 변경 | 과거 데이터는 기록 시 시간대 유지, 이후 새 시간대 |

---

## O. 수익화

| 항목 | 결정 |
|---|---|
| 모델 | **프리미엄** (무료 + Pro 구독) |
| 무료 | 수동 일정 + 펫 + 기본 일일 요약 + Lite 모드 (영구) |
| Pro | 모든 기능 (자동 스케줄 + 주/월 AI + Calendar + 패턴 학습 + 60일 휴지통 등) |
| 체험 | 무료 15일 (첫 7일 권한 없이 + 8일 권한 필수) |
| 결제 형태 | 월 + 연 둘 다 |
| 결제 백엔드 | RevenueCat |
| 광고 | **미정** (Open Decision, 다음 세션) |
| 취소 흐름 | 앱 내 취소 버튼 → RevenueCat → Play Store 리다이렉트 |
| 환불 후 권한 | 결제 기간 끝까지 Pro 유지 (Google 정책) |
| 결제 실패 | Google Play 유예 3일 + 경고 배너 |
| **MVP 포함** | **결제까지 포함** |

---

## P. UI / UX

| 항목 | 결정 |
|---|---|
| 메인 컬러 | **파스텔 그린** (숨쉬는 느낌) |
| 다크모드 | 시스템 설정 따라가기 + 수동 오버라이드 |
| 아트 스타일 | 픽셀 동물 펫 |
| 홈 화면 | **대시보드** (펫 + 일정 + 통계) |
| 사운드 | 주요 이벤트(레벨업·진화·부화)에 짧은 사운드 |
| 햅틱 | 탭·레벨업 |
| 펫 인터랙션 위치 | 홈·펫 탭 둘 다 |

---

## Q. 시스템 통합

| 항목 | 결정 |
|---|---|
| 홈스크린 위젯 | **1×1·2×2·4×2 세 가지 모두 제공** |
| 위젯 갱신 | 30분마다 + 앱 주요 이벤트 트리거 |
| 데이터 내보내기 | JSON + CSV |
| FCM 서버 푸시 | 정산·이벤트 |
| SNS 공유 | **카카오톡 + Instagram 스토리** 직접 공유 |
| 공유 이미지 | 워터마크만 (링크 없음) |

---

## R. 소셜

- **MVP에 결과 공유만** (이미지 저장 + 소셜 공유)
- 친구·리더보드: 없음 (v2 이후 검토)

---

## S. 출시

| 항목 | 결정 |
|---|---|
| 첫 출시 버전 | **1.0.0** |
| Play Store 카테고리 | 라이프스타일 |
| 베타 | **Closed Beta 5–10명** (가족·친구 직접 연락) |
| 출시 일정 | **단일 개발자, 3개월 내** (스프린트, 매우 야심찬 일정) |
| 핫픽스 정책 | 클라이언트 포스 + 서버 즉시 키리스 + Remote Config 모두 |
| 업데이트 주기 | **미정** (다음 세션) |

---

## T. 법규 / 운영

| 항목 | 결정 |
|---|---|
| PIPA / GDPR | 개인정보처리방침 + 설정 내 '내 데이터·삭제' 메뉴 |
| 사용자 문의 | 앱 내 입력 폼 → Supabase 제출 |
| 부정행위 | 서버 시간 기준 (시계 조작 차단) |
| 데이터 보존 | 90일 초과 raw usage_samples 자동 삭제 |

---

## 기술 아키텍처 (1차 초안)

### 디렉토리 구조

```
/Reward-Based-Self-Management-AppReward-Based-Self-Management-App/
├── PRD.md, Tasks.md, rules.md   # 거버넌스 (다음 세션 작성)
├── pubspec.yaml, analysis_options.yaml, l10n.yaml
├── lib/
│   ├── main.dart, app.dart
│   ├── core/
│   │   ├── config/ routing/ theme/
│   │   ├── db/ (Drift)
│   │   ├── native/ (Pigeon wrappers)
│   │   ├── notifications/
│   │   ├── sync/ (outbox)
│   │   ├── i18n/ (ko, en)
│   │   ├── errors/
│   │   └── constants/xp_rules.dart
│   └── features/
│       ├── onboarding/         # 5단계 + AI 첫 일정 제안 통합
│       ├── schedule/           # 수동 일정 + Calendar 연동
│       ├── focus_tracking/     # UsageStats + XP 산출
│       ├── pet/                # 캐릭터·HP·진화·인터랙션
│       ├── pet_dex/            # 펫도감 (실루엣 → 해금)
│       ├── hall_of_fame/       # 명예의 전당
│       ├── summary/            # 일일·주간 요약
│       ├── reports/            # AI 리포트 (인앱·이미지·PDF)
│       ├── auto_schedule/      # Pro - 자동 스케줄 검색
│       ├── widgets/            # 1×1·2×2·4×2 홈 위젯
│       └── profile/            # 계정·구독·설정
├── pigeons/usage_api.dart
├── android/app/src/main/
│   ├── AndroidManifest.xml
│   └── kotlin/com/.../
│       ├── bridge/ (Pigeon impl)
│       ├── usage/ (UsageStatsCollector)
│       ├── service/ (FocusForegroundService)
│       ├── permissions/
│       ├── alarm/
│       ├── notifications/
│       └── widgets/ (App Widget Provider)
├── server/                       # Cloudflare Workers (별도 디렉토리)
│   ├── src/
│   │   ├── routes/{ai,pdf,image_card,push,auth}.ts
│   │   ├── lib/{gemini,supabase_jwt,template}.ts
│   │   └── index.ts
│   └── wrangler.toml
└── docs/
```

### 중요 단일 출처 파일 (구현 시 핵심)
- `lib/core/constants/xp_rules.dart` — XP·HP 공식 단일 출처
- `lib/features/focus_tracking/application/xp_calculator.dart` — 순수 함수, 단위 테스트 ≥ 10케이스
- `lib/features/pet/domain/level_curve.dart` — 종별 진화 곡선 (3종)
- `lib/features/pet/domain/hp_curve.dart` — HP 가중치 차감 공식
- `pigeons/usage_api.dart` — Pigeon schema (Dart/Kotlin 양쪽 자동 생성)
- `android/app/src/main/AndroidManifest.xml` — 권한·서비스 declaration
- `android/app/src/main/kotlin/.../usage/UsageStatsCollector.kt` — UsageStats 핵심
- `android/app/src/main/kotlin/.../service/FocusForegroundService.kt` — Foreground Service

---

## 위험 요소 (현재 인식)

| # | 위험 | 영향 | 대응 |
|---|---|---|---|
| R1 | **3개월 출시 일정 vs 매우 큰 스코프** | 미출시 위험 | 페이즈별 DoD 엄격 적용, 스코프 추가 차단(rules.md) — *재검토 필요* |
| R2 | UsageStats 권한 거부 | 핵심 기능 무력화 | 완전 차단(권한 필수) + 첫 7일은 권한 없이도 체험 가능 |
| R3 | Doze/배터리 최적화로 Foreground Service 종료 | 데이터 손실 | 종료 시점 재조회(UsageStats는 OS 기록), 배터리 예외 안내 |
| R4 | **Gemini API 비용 폭증** | 운영비 손실 | Flash 모델, 압축 토큰, 자체 서버 캐시, Pro 우선 |
| R5 | Play Store Accessibility 정책 | 출시 거부 | 카톡/슬랙 추출은 Share intent로 대체 |
| R6 | **단일 개발자 번아웃** (3개월·매우 야심찬 스코프) | 출시 지연 | 페이즈별 회고 + 스코프 재검토(아래 권고 참조) |
| R7 | 펫 사망의 감정적 부담 vs 자기관리 동기 | 사용자 이탈 | 24시간 애도 + 명예의 전당으로 완화 |
| R8 | MIT 오픈소스 + 구독 모델 충돌 | 수익 모델 위험 | 구독 가치는 Gemini API·자체 서버·콘텐츠에 귀속 (앱 코드는 공개 가능) |
| R9 | 한+영 동시 i18n 작업량 | 출시 지연 | Phase 0부터 i18n 구조화, 자동 도구 활용 |
| R10 | Cloudflare Workers 자체 운영 | 인시던트 부담 | 단일 개발자 자체 모니터링, 추후 SaaS 이전 |
| R11 | Pigeon schema drift | 런타임 크래시 | Pigeon 강제, CI에 schema diff 검증 |
| R12 | UsageStats 데이터 정확도(`queryEvents` vs `queryUsageStats`) | XP 부정확 | `queryEvents` 기반 직접 합산, 합성 이벤트 단위 테스트 |

### ⚠️ R1·R6 권고 (다음 세션에서 사용자에게 제시)

야심찬 스코프(13세트 펫 아트 + 자동 스케줄 4종 소스 + AI 코치 + 결제 + 위젯 3종 + Cloudflare Workers + Supabase + RevenueCat + 한·영 i18n + 6개 알림 채널 + Closed Beta)를 1인 개발자가 3개월 안에 끝내기는 매우 어렵습니다.

**다음 중 하나를 권고**:

(a) MVP 스코프를 v1.0(1.5~2개월) → v1.1(3개월) → v1.2(4개월)로 분할
(b) MVP에서 Pro 기능(자동 스케줄·PDF·월간 리포트) 일부를 v1.1로 이연
(c) 펫 종을 1종으로 시작, 나머지 2종은 v1.1
(d) 위젯을 1종(2×2)만 출시, 나머지는 v1.1

---

## 다음 세션에서 이어갈 항목 (남은 결정사항)

### 미확인 / 더 깊이 들어갈 영역

1. **자체 서버(Cloudflare Workers)와 Supabase 인증 연결 방식**
   - JWT 검증 / API Key / Service Role 중 어느 것 (다음 세션 첫 번째로 묻기)
2. **일정·할일 카테고리·태그 정확한 정의**
   - 5개 고정 / 자유 태그 / 둘 다 — 사용자 모호한 답
3. **1.0.0 출시 이후 업데이트 주기 정책** (월 1회 / 격주 / 분기)
4. **클로즈드 베타 종료 후 피드백 수집·적용 흐름**
5. **AI 비용 통제 정책의 구체화** (Pro/무료 사용량 한도, 캐시 정책)
6. **광고 정책** — PRD Open Decision으로 등록 후 추후 결정
7. **첫 출시 후 운영 정책** (서버 헬스·인시던트 대응 SLA)
8. **데이터 내보내기 빈도 제한** (Free vs Pro)
9. **펫 별명 변경 카운트 저장 위치** (서버 vs 로컬)
10. **자체 서버 ↔ Supabase 데이터 흐름의 권위** — 정산 결과의 source of truth?
11. **알 부화 후 첫 펫과의 첫 상호작용** (자기소개·인사 멘트?)
12. **5개 카테고리 vs 자유 태그** (재확인)
13. **베타 → 출시 사이 안정화 단계 흐름**
14. **Phase별 상세 DoD 확정** (Phase 0~7)

### 사용자에게 권고할 사항 (R1·R6 관련)
- 3개월 일정에 대한 스코프 재검토
- 특히 자동 스케줄 검색 4종 소스 동시 출시 vs 1~2종 우선

---

## 다음 세션 시작 시 액션

1. **이 파일을 먼저 읽어** 컨텍스트 복원
2. **남은 결정사항 14개**를 사용자에게 추가 질문으로 진행
3. **스코프 재검토 권고** 제시 (R1·R6)
4. 충분히 모이면 **PRD.md / Tasks.md / rules.md 초안** 작성
5. 사용자 승인 → `~/.claude/templates/BOOTSTRAP.md` 따라 부트스트랩
6. 부트스트랩 후 Phase 0(Flutter scaffold + Cloudflare Workers scaffold) 진행

---

## Verification (PRD 확정 후 검증 항목)

PRD/Tasks/rules가 작성되면 다음을 검증:

- [ ] PRD §2 Confirmed Decisions에 위 A~T 카테고리의 결정사항 모두 반영
- [ ] PRD §9 Open Decisions에 광고·14개 미확인 항목 등재
- [ ] Tasks.md Phase 0 DoD가 명확
- [ ] rules.md scope guard가 야심찬 스코프 추가를 차단
- [ ] R1·R6에 대한 스코프 재검토 결과 반영
- [ ] Phase 0 DoD: `flutter analyze` 0 warning, `flutter run -d android` 빈 화면 부팅 성공, Pigeon 코드 생성 동작, PRD/Tasks/rules 3종 문서 존재, 더미 테스트 통과

---

**⚠️ 이 파일은 작성 중간 저장본이며, 코드 구현 시작 승인이 아닙니다. 다음 세션에서 추가 요구사항 수집을 계속한 후 정식 PRD/Tasks/rules로 확정해야 합니다.**

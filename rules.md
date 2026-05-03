# 루틴몬 — Project Rules

> **❄️ 동결 공지 (2026-05-03 거버넌스 전환)**:
> 이 문서는 거버넌스 시나리오 2 전환 시점에 **동결됨**. 신규 아키텍처 / 행동 결정은 `docs/adr/NNNN-*.md` 로 기록 (`/grill-with-docs` 호출). 기존 결정의 backfill 은 하지 않으며, 본 파일은 **pre-transition 결정 아카이브**로 살아있음. 신규 결정 시 본 파일을 갱신하지 말고 ADR 신설.
> 자세한 전환 배경은 `~/.claude/projects/-home-str-dgx-spark-Desktop-Reward-Based-Self-Management-AppReward-Based-Self-Management-App/memory/project_governance_transition.md` 참조.

> 이 문서는 프로젝트의 행동 규칙·아키텍처 가드·anti-pattern을 정의합니다. 변경 시 PR + 사용자 승인 필수.

---

## 1. Scope Guard

1.1 PRD §2(Confirmed Decisions)에 없는 기능은 추가 금지
1.2 새 기능 제안은 PRD §9 Open Decisions에 등록 후 결정 deadline 지정
1.3 "이왕 하는 김에" 추가 구현 금지
1.4 Backlog 항목을 현재 페이즈에 끌어오려면 PRD 변경 PR 필요
1.5 v1.0 스코프는 PRD §3.1 "MVP Scope > In"으로 고정. 변경 시 사용자 승인 + 회고 필수

---

## 2. Phase Discipline

2.1 페이즈는 순차 실행 (Phase 0 → 7). Phase N의 DoD 미충족 상태에서 Phase N+1 작업 금지
2.2 페이즈 내부는 멀티 워커(warm pool) 병렬 가능하나, 페이즈 경계는 직렬
2.3 DoD 충족 판정 시 인용 출처 명시 (테스트 결과, 빌드 로그, 사용자 검토 기록 등)
2.4 페이즈 종료 시 Tasks.md Retrospectives에 1줄 이상 기록
2.5 일정 지연 시 스코프 축소가 아니라 우선순위 재조정 (사용자 결정 필요)

---

## 3. Architecture

3.1 Feature-first 디렉토리 구조 (`lib/features/<도메인>/`). `core/`는 도메인 무관 인프라만
3.2 의존성 방향: presentation → application → domain ← data
3.3 domain layer는 Flutter/Android/Supabase/RevenueCat 등 framework import 금지 (순수 Dart)
3.4 native bridge는 **Pigeon 강제**, 수기 MethodChannel 금지
3.5 단일 source of truth = Drift database. SharedPreferences는 UI 설정만
3.6 XP/HP/진화 공식은 `lib/core/constants/xp_rules.dart` 단일 출처
3.7 모든 write는 Drift commit + outbox enqueue 패턴
3.8 일일 정산은 클라이언트 권위 (오프라인 동작 보장)

---

## 4. Code Quality

4.1 `flutter analyze` 0 warning이 머지 조건
4.2 freezed 모델은 불변 + sealed union 권장
4.3 Riverpod provider는 `@riverpod` 코드 생성 사용
4.4 도메인 함수(특히 XpCalculator, HpCurve, LevelCurve)는 순수 함수 + 단위 테스트 필수
4.5 한국어/영어 i18n 키 분리, 하드코딩 텍스트 금지
4.6 Lint: very_good_analysis 또는 사내 ruleset 강제

---

## 5. Testing

5.1 새 도메인 함수 추가 시 단위 테스트 동시 작성
5.2 Repository는 in-memory Drift로 테스트
5.3 native bridge는 통합 테스트로 검증
5.4 XpCalculator/HpCurve/LevelCurve 단위 테스트 ≥ 15케이스 (경계, 가중치, overflow, 리셋)
5.5 mocktail 사용 (mockito 금지 — 코드 생성 의존 회피)

---

## 6. Permissions / Privacy

6.1 신규 권한 추가는 PRD 변경 필요
6.2 UsageStats 데이터는 raw 형태로 클라우드 전송 금지 (집계만 전송)
6.3 90일 초과된 raw usage_samples는 자동 삭제
6.4 사용자 데이터는 LLM 호출 전 익명화 (이름·메모 제거, 패키지명 해시) — 로컬/원격 LLM 무관
6.5 PIPA·GDPR 준수 — 설정에 '내 데이터·삭제 권한' 메뉴 필수
6.6 계정 탈퇴 시 30일 후 완전 삭제

---

## 7. Native Android

7.1 minSdk 26, targetSdk 34
7.2 ForegroundService는 type=`dataSync` 명시
7.3 Battery optimization 우회는 사용자 동의 후만
7.4 권한은 온보딩 권한 탭에서 일괄 청구 (just-in-time 금지)
7.5 UsageStats는 `queryEvents` 기반 직접 합산 (queryUsageStats는 검증용)

---

## 8. Cloud / Server

> **2026-04-18 rev 9 갱신**: Cloudflare Workers 전면 제거, n8n self-hosted + 로컬 LLM이 기본 스택. 개발 비용 최소화 원칙(PRD §2.14)에 따라 유료 cloud 서비스 도입은 v1.0까지 금지.

8.1 자체 서버 인증 = Supabase JWT + JWKS 검증 (Service Role 사용 금지, 최소 권한)
8.2 환경변수/비밀 관리는 `.env` (루트, git-ignored) + n8n Credentials만 사용. 하드코딩 금지. 프로덕션 별도 저장소는 Phase 6 이후 재평가.
8.3 RLS 정책 없는 Supabase 테이블 생성 금지
8.4 AI 출력은 콘텐츠 검사 레이어(n8n 워크플로우 내부) 통과 후 클라이언트로 전달 (욕설·자해 차단)
8.5 dev/staging/prod 환경 분리는 베타(Phase 6) 이후 재평가. 현재 단일 n8n self-hosted 인스턴스 운영.
8.6 시간 기준은 서버 시간 (부정행위 방지)
8.7 유료 cloud 서비스 신규 도입 시 PRD §2.14 개발 비용 정책 위반 여부 확인 + 사용자 승인 필수 (허용 유료: Supabase self-hosted + RevenueCat + Firebase FCM 무료 티어)

---

## 9. AI / LLM

> **2026-04-18 갱신**: Gemini Flash → 로컬 LLM via n8n 전환 (PRD §2.15). 본 섹션은 LLM 제공자와 무관하게 적용되는 일반 규칙이다.

9.1 AI 호출은 자체 서버(현재 n8n) 경유만, 클라이언트 직접 LLM 호출 금지
9.2 시스템 프롬프트는 n8n 워크플로우에 고정, 사용자 입력은 구조화 데이터(JSON)만
9.3 호출 실패 시 3회 재시도 → 폴백 수치 리포트 (사용자 경험 보호)
9.4 무료 사용자에게 AI 호출 금지 (Pro 전용)
9.5 토큰/지연 모니터링 + 로깅 (로컬 GPU throughput 통제, PRD §2.15.1 참조)
9.6 LLM 제공자 변경 시 PRD §2.15 + §2.15.1 동시 갱신 필수 (§10.1과 연동)

---

## 10. Decision Log

10.1 결정 변경 시 PRD §2 update + Decision Log에 사유 기록
10.2 Open Decision 해결 시 PRD §9에서 §2로 이동 (~~취소선~~ 표시)

---

## 11. Anti-Patterns (금지 목록)

- 수기 MethodChannel
- domain layer의 framework import
- DoD 없는 태스크 생성
- 페이즈 건너뛰기
- "임시" 코드 (TODO 100개)
- Tasks.md 직접 [x] 전환 (DoD 인용 없는 경우)
- 사용자 raw 텍스트를 LLM에 그대로 전달 (로컬 LLM 포함 익명화 필수, §6.4)
- Service Role Key 클라이언트 노출
- APK에 API Key 임베드 (JWT만 사용)
- 광고 SDK 추가 (광고 없음 정책)
- 네이티브 코드의 강제 종료 (Foreground Service 정상 종료만)

# 루틴몬 — Analytics Events Specification

> Source of truth: 이 파일 (PRD §2.22.1)
> 작성 방식: 페이즈별 incremental (PRD §2.22.2)
> Last Updated: 2026-05-03

---

## Event Schema (PRD §2.22.3)

각 이벤트는 다음 6개 필드를 가진다:

| 필드 | 설명 |
|---|---|
| event_name | 이벤트 고유 이름 (snake_case) |
| trigger | 발생 시점/조건 |
| properties | 이벤트 속성 (key: type) |
| kpi_mapping | 연결된 KPI (PRD §8) |
| phase | 정의된 Phase 번호 |
| sdks | 전송 대상 SDK [posthog, firebase_analytics] |

---

## User Properties (PRD §2.22.4)

PostHog/Firebase identify 호출 시 전달:

| Property | 타입 | 값 |
|---|---|---|
| plan | enum | free, trial, pro, lite |
| locale | string | ko, en |
| pet_species | enum | bird, dragon, dolphin, none |
| current_pet_level | int | 0~5 |
| signup_date | ISO8601 | |
| total_pets_died | int | 명예의 전당 카운트 |
| subscription_started_at | ISO8601 (nullable) | |
| app_version | string | |
| android_sdk_int | int | |

---

## KPI <-> Event Mapping (PRD §2.22.5)

| KPI (§8) | 목표 | 측정 이벤트 | 계산 방식 |
|---|---|---|---|
| D7 retention | >= 30% | app_open | signup 후 7일째 app_open 유저 / 7일 전 signup 유저 |
| 주간 평균 세션 수 | >= 5 | focus_session_started | 주간 합계 / 활성 유저 |
| 평균 focus ratio | >= 70% | daily_score_recorded (focus_ratio property) | 일일 평균 |
| 무료->Pro 전환율 | >= 5% | paywall_viewed -> purchase_completed | 퍼널 전환율 |
| Crash-free user rate | >= 99% | (Sentry 자동) | Sentry KPI |

---

## Core Funnels (PRD §2.22.6)

### 온보딩 5단계
signup_started -> signup_completed -> onboarding_step_1 -> onboarding_step_2 -> onboarding_step_3 -> onboarding_step_4 -> onboarding_step_5 -> egg_hatched -> pet_named

### 결제 3단계
paywall_viewed -> purchase_initiated -> purchase_completed

### 첫 집중 세션
pet_named -> schedule_created -> focus_session_started -> focus_session_ended

### 펫 진화
focus_session_ended (XP 누적) -> pet_evolved

---

## Phase 1 Events

### usage_permission_requested
- **event_name**: usage_permission_requested
- **trigger**: 온보딩 권한 탭에서 UsageStats 권한 요청 버튼 탭
- **properties**: { }
- **kpi_mapping**: 온보딩 퍼널 drop-off 분석
- **phase**: 1
- **sdks**: [posthog, firebase_analytics]

### usage_permission_granted
- **event_name**: usage_permission_granted
- **trigger**: Settings에서 돌아온 후 hasUsagePermission() == true 감지
- **properties**: { time_to_grant_ms: int }
- **kpi_mapping**: 온보딩 퍼널 drop-off 분석
- **phase**: 1
- **sdks**: [posthog, firebase_analytics]

### usage_permission_denied
- **event_name**: usage_permission_denied
- **trigger**: Settings에서 돌아온 후 hasUsagePermission() == false (사용자가 거부하고 돌아옴)
- **properties**: { attempt_count: int }
- **kpi_mapping**: 온보딩 퍼널 drop-off 분석, D7 retention
- **phase**: 1
- **sdks**: [posthog, firebase_analytics]

### blacklist_app_added
- **event_name**: blacklist_app_added
- **trigger**: 사용자가 블랙리스트에 앱 추가
- **properties**: { package_name_hash: string, source: enum [preset, manual] }
- **kpi_mapping**: 평균 focus ratio (블랙리스트 설정이 focus_ratio에 직접 영향)
- **phase**: 1
- **sdks**: [posthog, firebase_analytics]

---

## Phase 2~6 Events (해당 페이즈에서 추가)

> Phase 2~6 이벤트는 해당 페이즈 진입 시 이 섹션에 incremental로 추가됩니다.
> PRD §2.22.2 참조.

### Phase 2 — Auth + Schedule + Pet

#### signup_started
- **event_name**: signup_started
- **trigger**: 온보딩 2단계에서 로그인 버튼 탭 (Google Sign-In 시작)
- **properties**: { method: enum [google] }
- **kpi_mapping**: 온보딩 퍼널 (PRD §2.22.6), D7 retention
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### signup_completed
- **event_name**: signup_completed
- **trigger**: Supabase Auth 로그인 성공 (JWT 발급)
- **properties**: { method: enum [google], user_id_hash: string }
- **kpi_mapping**: 온보딩 퍼널, D7 retention
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### onboarding_step_1 ~ onboarding_step_5
- **event_name**: onboarding_step_{1..5}
- **trigger**: 온보딩 각 단계 진입 시 (1:소개, 2:로그인, 3:권한, 4:집중시간, 5:알선택)
- **properties**: { step: int, skipped: bool }
- **kpi_mapping**: 온보딩 퍼널 drop-off (PRD §2.22.6)
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### egg_chosen
- **event_name**: egg_chosen
- **trigger**: 온보딩 5단계에서 알 종류 선택 완료
- **properties**: { species: enum [bird, dragon, dolphin] }
- **kpi_mapping**: 온보딩 퍼널
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### egg_hatched
- **event_name**: egg_hatched
- **trigger**: 알 부화 5단계 애니메이션 완료 (펫 등장)
- **properties**: { species: enum [bird, dragon, dolphin], hatch_duration_ms: int }
- **kpi_mapping**: 온보딩 퍼널, 첫 집중 세션 퍼널 (PRD §2.22.6)
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### pet_named
- **event_name**: pet_named
- **trigger**: 펫 별명 입력 + PetNameValidator 통과 + Drift INSERT 완료
- **properties**: { species: enum [bird, dragon, dolphin], name_length: int }
- **kpi_mapping**: 온보딩 퍼널 최종 단계
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### schedule_created
- **event_name**: schedule_created
- **trigger**: 일정/할일 생성 → Drift INSERT + outbox enqueue 완료
- **properties**: { category: enum [work, study, hobby, health, etc], is_todo: bool, has_tags: bool }
- **kpi_mapping**: 주간 평균 세션 수 (간접), 첫 집중 세션 퍼널
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

#### task_created
- **event_name**: task_created
- **trigger**: 시간 없는 할일(to-do) 생성 → Drift INSERT + outbox enqueue 완료
- **properties**: { category: enum [work, study, hobby, health, etc] }
- **kpi_mapping**: 주간 활성 사용 (간접)
- **phase**: 2
- **sdks**: [posthog, firebase_analytics]

### Phase 3 — Focus Tracking & XP/HP

#### focus_session_started
- **event_name**: focus_session_started
- **trigger**: 사용자가 집중 세션 시작 (FocusSessionController.startSession)
- **properties**: { session_id: string(uuid), planned_duration_min: int, schedule_id: string(nullable), source: enum [manual, scheduled, calendar] }
- **kpi_mapping**: 주간 평균 세션 수 (PRD §8), focus_ratio 계산 입력
- **phase**: 3
- **sdks**: [posthog, firebase_analytics]

#### focus_session_ended
- **event_name**: focus_session_ended
- **trigger**: 집중 세션 종료 (FocusSessionController.stopSession)
- **properties**: { session_id: string, duration_min: int, focus_ratio: double, grade: enum [S,A,B,C,D], xp_earned: int, hp_change: int, blacklist_usage_min: int }
- **kpi_mapping**: 주간 평균 세션 수, 평균 focus ratio (PRD §8)
- **phase**: 3
- **sdks**: [posthog, firebase_analytics]

#### daily_score_recorded
- **event_name**: daily_score_recorded
- **trigger**: 일일 정산 완료 (DailySettlement.settle 결과 Drift INSERT)
- **properties**: { date: ISO8601, grade: enum [S,A,B,C,D], focus_ratio: double, xp_earned: int, hp_change: int, new_hp: int, new_xp: int, task_penalty: int, consecutive_d_count: int }
- **kpi_mapping**: 평균 focus ratio ≥ 70% (PRD §8 핵심 KPI)
- **phase**: 3
- **sdks**: [posthog, firebase_analytics]

#### pet_evolved
- **event_name**: pet_evolved
- **trigger**: 일일 정산 시 진화 임계 도달 (LevelCurve.checkEvolution)
- **properties**: { pet_id: string, species: enum [bird,dragon,dolphin], previous_level: int, new_level: int, total_xp: int }
- **kpi_mapping**: 펫 진화 퍼널 (PRD §2.22.6)
- **phase**: 3
- **sdks**: [posthog, firebase_analytics]

#### hp_critical
- **event_name**: hp_critical
- **trigger**: 일일 정산 후 HP ≤ 20
- **properties**: { pet_id: string, current_hp: int, consecutive_d_count: int }
- **kpi_mapping**: D7 retention (위기 알림 → 행동 변화 유도)
- **phase**: 3
- **sdks**: [posthog, firebase_analytics]

#### pet_died
- **event_name**: pet_died
- **trigger**: 일일 정산 후 HP ≤ 0 → isAlive=false (LevelCurve.shouldDie)
- **properties**: { pet_id: string, species: enum [bird,dragon,dolphin], death_cause: enum [hp_zero, neglect], total_xp: int, survival_days: int, avg_focus_ratio: double }
- **kpi_mapping**: D7 retention (사망 → 이탈 위험)
- **phase**: 3
- **sdks**: [posthog, firebase_analytics]

### Phase 4 — Pet Art + Evolution + Interaction (예정)
<!-- pet_interaction_feed, pet_interaction_pet, pet_interaction_play, pet_dex_unlocked, hall_of_fame_viewed -->

### Phase 5 — AI Reports + 결제 + 위젯 (예정)
<!-- paywall_viewed, purchase_initiated, purchase_completed, purchase_failed, trial_started, trial_expired, lite_demoted, weekly_report_viewed, widget_added, auto_schedule_imported, share_intent_processed -->

### Phase 5 — Weekly Wizard v2 (정의됨, 발송 wiring 은 후속, ADR 0001 참조)

#### `wizard_generated`
- **trigger**: `WeeklyWizardService.generate()` 가 응답 반환 직후 (UI 측에서 호출)
- **properties**: { path: enum [rule, llm, preset], items_count: int, conflicts_count: int, warnings_count: int, has_past_week_context: bool }
- **kpi_mapping**: 주간 wizard 채택율, Path A vs B 분포 측정
- **phase**: 5
- **sdks**: [posthog, firebase_analytics]

#### `wizard_conflict_detected`
- **trigger**: `WeeklyWizardResponse.conflicts` 에 항목이 존재할 때, conflict 별 1회 발송
- **properties**: { kind: enum [time_overlap, existing_overlap, no_break, category_monotony, outside_awake], severity: enum [error, warning] }
- **kpi_mapping**: 충돌 발생 빈도 → ADR 0002 임계치 튜닝 신호
- **phase**: 5
- **sdks**: [posthog]

#### `wizard_enhanced`
- **trigger**: `WeeklyWizardService.enhance()` 가 LLM 응답으로 성공 반환 시 (Pro 옵트인)
- **properties**: { objective: enum [diversify_titles, rebalance_load, add_recovery, refine_categories], turn: int, retry_count: int, items_count: int }
- **kpi_mapping**: Pro 사용자 enhance 채택율, retry 분포
- **phase**: 5
- **sdks**: [posthog, firebase_analytics]

#### `wizard_applied`
- **trigger**: `WizardPreviewPage._apply()` 트랜잭션 성공 직후
- **properties**: { path: enum [rule, llm, preset], items_count: int, confirm_after_conflict: bool, refinement_turns: int }
- **kpi_mapping**: wizard funnel 종료 지점 (생성 → 적용)
- **phase**: 5
- **sdks**: [posthog, firebase_analytics]

### Phase 6 — Closed Beta (예정)
<!-- beta_tester_invited, beta_session, feedback_submitted -->

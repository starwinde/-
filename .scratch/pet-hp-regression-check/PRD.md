# Plan 3 — 펫 기능 + 실시간 HP 감소 점검 / 복구

> 2026-05-11 작성. 이후 `superpowers:systematic-debugging` / `diagnose` / `tdd` 등 추가 스킬로 구체화 예정.

## 배경

rev 31~34 동안 펫 시스템에 대량 wiring 추가. 같은 시기에 위저드 분기 충돌, 환경 마이그레이션 (X64 ↔ ARM), 거버넌스 전환이 동시 진행되어 **개발 도중 회귀가 생겼을 가능성** 이 있음.

사용자 명시 2026-05-11: "펫 기능과 실시간 사용자 행동에 따른 체력 감소 기믹도 제대로 작동하는지 점검하고 해당 부분도 해결하는걸 계획에 추가. 개발 도중 깨졌을 수도 있으니."

## 점검 대상

| 항목 | 도입 시점 | 메모리 노트 |
|---|---|---|
| Focus pipeline (일정 종료 시 사용 통계 정산 → 펫 HP 차감) | rev 31 `de00286` | "풀-루프 E2E 보류, WorkManager callback 본체는 별 task" |
| 펫 인터랙션 (먹이/쓰다듬/놀아주기) | rev 33 `d88d561` | 디바이스 확인 기록 없음 |
| Sticky 알림 (활성 일정) | rev 34 `27b7325` | 디바이스 확인 기록 없음 |
| **실시간 HP 감소** | **미확정** | rev 31 은 "정산형" (일정 종료 시 일괄 차감). 실시간 감소 wiring 존재 여부 미확인 |

## 목표

1. rev 31~34 펫 코드의 정적/단위 회귀 0 건
2. 디바이스 E2E (Samsung Note20) 에서 풀-루프 동작 확인
3. **실시간 HP 감소** 의 현재 구현 상태 명확화 (있음/없음), 없으면 신규 구현 계획 추가

## 작업 단계

### A. 정적 점검 (PC 만으로 가능)

- [ ] `flutter analyze` 0 error 유지 확인
- [ ] rev 31~34 추가 코드의 import 그래프가 끊김 없이 연결되어 있는지 점검
- [ ] WorkManager / ForegroundService 진입점이 `AndroidManifest.xml` 에 정상 등록되어 있는지
- [ ] Provider 그래프 (`PetRepository` ← `PetInteractionRepository` ← `PetInteractionService` 등) 가 dispose 누락 없이 wired 되어 있는지

### B. unit test 회귀

- [ ] `flutter test` 전체 통과 (현재 63개 기준)
- [ ] 펫 HP 곡선 (`hp_curve.dart`) / 레벨 (`level_curve.dart`) 정확도
- [ ] 인터랙션 (`pet_interaction_service.dart`) 쿨다운/상태 변화
- [ ] 정산 (`SettlementOrchestrator`) 일정 종료 시 HP 차감 로직

### C. 디바이스 E2E (Samsung Note20, `R3CN70T28CZ`)

> 제약: `reference_device_e2e.md` 메모리 — uiautomator dump 무효 (Flutter Skia), sqlite3 부재, install -t 필수. **수동 시각 확인 필수**.

- [ ] 일정 등록 → 시작 → 폰 사용 → 일정 종료 → 펫 HP 변화 확인 (Focus pipeline 풀-루프)
- [ ] 펫 인터랙션 3종 동작 (먹이/쓰다듬/놀아주기) + 쿨다운 표시
- [ ] Sticky 알림 표시 / 일정 종료 시 자동 해제
- [ ] 인터랙션 후 HP/XP 반영 즉시성

### D. 실시간 HP 감소 wiring 점검

> "실시간" 의 정확한 의미 = **Open Decision** (분당 / 5분당 / 이벤트 기반 — 사용자 결정 필요)

- [ ] 현재 코드에서 "실시간 HP 감소" 진입점 grep — `disturbance` / `usage_event` / `focus_loss` 등
- [ ] 정산형(rev 31) 만 있는 게 사실인지 확인
- [ ] 미구현이면: **신규 구현 이슈 추가**
  - 트리거: 블랙리스트 앱 진입 즉시 vs 일정 시간 윈도우 (1분/5분) 단위
  - 차감 폭: 시간 비례 vs 즉시 정해진 양
  - 디바운싱 / 중복 차감 방지
  - 배터리 영향 분석 (WorkManager periodic? ForegroundService?)

## DoD

- [ ] A/B/C 통과 (모든 체크박스 ✅)
- [ ] D 의 현재 구현 상태 명시 (있음/없음), 없으면 신규 구현 PRD 별도 작성
- [ ] 깨진 부분이 발견되면 fix commit 단위로 정리 + 회귀 테스트 추가

## Open Decisions

1. **"실시간 HP 감소" 의 정의** — 분당? 5분당? 블랙리스트 앱 진입 즉시? (사용자 결정)
2. **차감 정책** — 시간 비례 vs 고정 양?
3. **디바이스 검증 트리거** — 사용자가 일정 직접 등록할지, dev 단축 버튼 사용할지 (rev 31 PetDetailPage 에 dev 정산 버튼 존재)
4. **WorkManager callback 본체 분리 task** — 그 task 의 구체 범위 확정 (rev 31 미완 항목)

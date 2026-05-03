# usage-tracking-l0 — 실기기 검증 보고서 (skeleton)

> Issue 05 산출물. 실기기 (Android) 시나리오 PASS/FAIL + 로그/스크린샷.
> Status: **PENDING — 이슈 01~04 완료 후 진행**

## 환경 점검

- Supabase Docker: ✅ healthy (이전 세션 5h+ uptime 확인)
- ADB devices: ✅ R3CN70T28CZ
- llama-server-8600: ❌ down (LLM 의존 없음, 본 작업 영향 없음)
- UsageStats 권한: ✅ 온보딩 완료 (이전 세션)

## 자동 테스트 (휴대폰 미연결 상태에서 가능한 부분)

- `flutter analyze`: TBD
- `flutter test`: TBD (목표: 162/162 회귀 0 + 신규 ≥ 25)

## 시나리오 (실기기 — 미실행)

### 시나리오 1: L0 일정 + 다른 앱 사용 → 홈 카드 누적
- **목표**: L0 일정 진행 중 Chrome 등 다른 앱 사용 → 루틴몬 복귀 → 홈 카드 1건 이상
- **체크리스트**:
  - [ ] 진동/오버레이/홈 이동 동작 0건
  - [ ] 홈 카드 top-3 표시 (Chrome 1건 이상)
  - [ ] usage_logs 행 count ≥ 1

### 시나리오 2: L2 일정 + 다른 앱 사용 → 차단 + 기록
- **목표**: L2 차단 다이얼로그 + 홈 강제 이동 정상 + 동시에 사용 기록 누적
- **체크리스트**:
  - [ ] 차단 다이얼로그 표시
  - [ ] 홈 강제 이동
  - [ ] usage_logs 행 count ≥ 1

### 시나리오 3: 홈 카드 자세히 보기 → 7일 토글
- **목표**: `/usage/history` 진입 + 7일 / 30일 토글 + 데이터 일관성
- **체크리스트**:
  - [ ] 라우트 진입 정상
  - [ ] 7일 토글 시 데이터 변화
  - [ ] 빈 상태 메시지 (1주 이상 데이터 0건 시)

### 시나리오 4: 본인 패키지 필터
- **목표**: 루틴몬 자체는 usage_logs 에 기록되지 않음
- **체크리스트**:
  - [ ] 루틴몬 포그라운드 5분 후 paused→resumed → 본인 패키지 row 0건

### 시나리오 5: queryUsageStats 실패 swallow
- **목표**: native API 가 실패해도 controller 가 차단/오류 표시 없이 다음 사이클 정상 동작
- **체크리스트**:
  - [ ] adb 로 권한 강제 회수 후 paused→resumed 진행 → 앱 충돌 0건, 다음 사이클 정상

## 후속 액션

- 이슈 01~04 완료 → 본 보고서 업데이트
- prune 정책 (30/90일) 별도 이슈 분리
- 표시명 매핑 (PackageManager) 별도 이슈 분리

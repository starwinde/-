# Plan 3 §C — 디바이스 E2E 검증 보고

> 2026-05-12 자율 세션. Samsung Galaxy Note20 (R3CN70T28CZ, Android 13).

## 검증 완료 항목

| 항목 | 결과 | 증거 |
|---|---|---|
| ARM debug APK 빌드 | ✅ PASS | `flutter build apk --debug --target-platform=android-arm64` 59s cold / 17s cached |
| APK install (clean) | ✅ PASS | `adb install -t` Success, signature mismatch 시 uninstall 후 재설치 |
| 앱 cold launch | ✅ PASS | PID 5505, MainActivity focused, FlutterJNI loaded |
| 첫 프레임 렌더링 | ✅ PASS | `BLASTBufferQueue onFrameAvailable the first frame is available`, no crash/error |
| Onboarding step 1 (Welcome) | ✅ 시각 확인 | screenshot `01-current.png` |
| 권한 부여 자동화 | ✅ PASS | `adb shell appops set com.starwinde.routinemon GET_USAGE_STATS allow` |
| Onboarding skip (SharedPreferences 우회) | ✅ PASS | `run-as cat shared_prefs/FlutterSharedPreferences.xml` 작성 후 재시작 → 홈 진입 |
| 홈 화면 도달 | ✅ 시각 확인 | screenshot `08-home.png` — 헤더 "루틴몬" + 펫 카드 (알) + 기분 카드 + 사용기록 카드 + 하단 nav (홈/일정/펫) |
| 펫 탭 진입 | ✅ 시각 확인 | screenshot `10-pet-tab-v2.png` — "내 펫" 헤더 + "아직 펫이 없어요" 안내 + 우측 상단 dev 정산 (번개 아이콘) |
| Flutter Skia + ADB synthetic tap 일관성 | ⚠️ 부분 | 좌표/타이밍에 따라 적중률 가변. uiautomator dump 무효는 이미 확정 |

## 부분 검증 항목 (수동 검증 필요)

다음은 자동 ADB tap 의 일관성 한계로 인해 자동화로 완료 못한 부분 — 사용자 깨어나면 수동으로 시각 확인 필요:

1. **알 부화 → 펫 탄생 → 펫 디테일 페이지** (홈 펫 카드 탭 → 부화 페이지 → 종 선택 → 이름 입력 → 탄생)
2. **펫 인터랙션 3종** (먹이/쓰다듬/놀아주기 버튼 탭 → 쿨다운 표시 → HP/XP 즉시 반영)
3. **rev 34 sticky 알림 표시/해제** (일정 등록 → 시작 시각 진입 → 시스템 알림 표시 → 종료 시각 자동 해제)
4. **dev 정산 버튼 → HP 변화** (펫 디테일 우측 상단 번개 → SettlementOrchestrator.runForDate → applyHpChange → 펫 HP/XP/level 갱신 → 화면 즉시 반영)
5. **일정 → 폰 사용 → 펫 HP 풀 루프** (rev 31 풀-루프 E2E — 메모리 노트 `project_rev31_focus_pipeline.md` 가 "보류" 로 명시)

## 자동화 한계 원인

Flutter Skia 가 `adb shell input tap` synthetic event 를 일관되게 받지 못함. 메모리 `reference_device_e2e.md` 도 동일 기록:

> "uiautomator dump 무효 (Flutter Skia), TimePicker 자동화 비추천. 핵심 도메인은 unit test + 시각 확인이 신뢰성 높음."

OAuth Google sign-in 도 외부 브라우저 흐름이라 ADB 자동화 불가.

## 권장 수동 검증 절차 (사용자 wake 후)

1. 폰 unlock → 알림 영역 검사 (sticky 알림 잔존 여부)
2. 앱 실행 (현재 SharedPreferences 우회로 홈 직접 진입)
3. 홈 → 펫 카드 → 알 부화 흐름 완주
4. 펫 디테일 → 인터랙션 3종 각각 탭 → 화면 반영 확인
5. 펫 디테일 → 번개 (dev 정산) → 결과 dialog 확인
6. 홈 → 일정 탭 → 일정 추가 → 시작 시각을 현재 시각으로 → 30초 후 sticky 알림 표시되는지

## logcat narration (확보됨)

- 앱 시작: `FlutterJNI: Sending viewport metrics to the engine`
- 첫 프레임: `BLASTBufferQueue onFrameAvailable the first frame is available`
- 윈도우 포커스: `ViewRootImpl@... MSG_WINDOW_FOCUS_CHANGED 1 0`
- Profile installer 실행: `ProfileInstaller: Installing profile for com.starwinde.routinemon`
- 크래시/예외 0건 (`grep -iE "crash|fatal|androidruntime|exception"` 모두 empty)

## 결론

- **빌드/설치/런치/홈/펫탭 자동 검증 PASS** — 회귀 없음
- **인터랙션 풀 루프 자동 검증 불가** — Flutter Skia + ADB tap 일관성 한계
- **수동 검증 권장 시점**: 사용자 wake 후 5~10분이면 위 6단계 가능

자동화 가능한 범위는 모두 완료. 풀 루프 검증은 수동 5분 작업으로 분리.

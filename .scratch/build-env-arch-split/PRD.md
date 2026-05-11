# Plan 1 — 컴파일 환경 정합 (ARM64 ↔ X64)

> 2026-05-11 작성. 이후 `superpowers:writing-plans` / `to-issues` 등 추가 스킬로 구체화 예정.

## 배경

GitHub history-reset 측 (v0.1.0 = `7e09180`) 은 데스크탑 X64 환경에서 작업되었고, 현재 로컬 (`5d9395a`) 은 DGX Spark ARM64 환경에서 작업 중. 두 환경의 `android/gradle.properties` 가 상호 비호환 상태.

| 항목 | v0.1.0 (X64) | 현재 main (ARM64) |
|---|---|---|
| JVM heap | `-Xmx4G` `MaxMetaspaceSize=2G` | `-Xmx8G` `MaxMetaspaceSize=4G` |
| `java.home` | JAVA_HOME 자동 | `/usr/lib/jvm/java-21-openjdk-arm64` 강제 |
| `java.library.path` | 미지정 | `/lib/aarch64-linux-gnu` 강제 |
| `android.injected.build.abi` | 미설정 (universal) | `arm64-v8a` 강제 |
| Gradle daemon/parallel/caching | 명시 활성화 | 미명시 |
| Kotlin incremental | 명시 활성화 | 미명시 |
| R8 fullMode | `false` | 미설정 |

**중대 단서**: 현재 main 주석 — "ARM64 host → x86_64 NDK 코어덤프 회피". universal APK 빌드 시도하면 ARM 호스트에서 빌드 자체가 죽음.

**CI 측**: `.github/workflows/release.yml` 은 `runs-on: ubuntu-latest` (X64). 로컬용 ARM 설정을 그대로 commit 하면 CI 깨짐.

## 목표

로컬 (DGX Spark ARM64) 와 CI (ubuntu-latest X64) 양쪽에서 같은 코드베이스가 빌드되도록 환경별 설정 분리.

## 비목표

- universal APK 지원 (ARM 호스트에서 빌드 불가 — 디바이스가 arm64-v8a Note20 이므로 단일 ABI 로 충분)
- macOS / Windows 빌드 지원 (현 단계 미고려)

## 설계 후보 (이후 grill-me/grill-with-docs 로 결정)

### Option A — env-overlay 패턴
- `android/gradle.properties` 는 공통 설정만 (heap, daemon, parallel, kotlin incremental, R8)
- 로컬 ARM: `~/.gradle/gradle.properties` 에 `java.home`, `java.library.path`, `android.injected.build.abi` overlay
- CI X64: `release.yml` 에서 별도 overlay 불필요 (기본값 사용)

### Option B — ENV var 분기
- `ORG_GRADLE_PROJECT_localArch=arm64` 등 환경변수로 `build.gradle.kts` 안에서 조건 분기
- CI / 로컬 모두 자동

### Option C — local.properties 활용
- `android/local.properties` 에 ARM 전용 설정 (.gitignore 처리)
- CI 측은 `release.yml` 이 동적 생성 (이미 dabe80e commit 패턴 존재)

## DoD

- [ ] 로컬 ARM 에서 `flutter build apk --debug --target-platform=android-arm64` 성공
- [ ] CI tag push 시 `release.yml` 성공 (X64)
- [ ] 두 환경 빌드 시간 회귀 없음 (X64 데스크탑 빌드 최적화 보존)
- [ ] 결정한 옵션에 대해 ADR 작성 또는 `docs/build-env.md` 단일 문서로 정합 규칙 명시

## 선결 검증 (작업 시작 전)

```bash
flutter build apk --debug --target-platform=android-arm64
```

현재 main 베이스라인. 성공 확인 후 작업 시작. 실패면 root cause 우선 진단 (별 이슈).

## Open Decisions

- A / B / C 중 선택
- `.gitignore` 패턴 (overlay 파일 위치)
- CI runner 를 `ubuntu-24.04-arm` (GitHub Actions 의 ARM runner) 로 옮길지 여부 — 옮기면 분기 불필요해질 수 있으나 빌드 시간 변경

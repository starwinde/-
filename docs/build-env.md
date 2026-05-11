# Build Environment — ARM64 / X64 split

> 2026-05-12. Resolves Plan 1 (`.scratch/build-env-arch-split/PRD.md`).
> Implements env-overlay pattern (Eng review Option A) with corrected Gradle precedence.

## Premise

This project is developed on **DGX Spark ARM64** but CI runs on **ubuntu-latest X64** (`.github/workflows/release.yml`). Native NDK toolchain on the ARM host cannot cross-compile to x86_64 without coredumping, while CI cannot find ARM-specific JDK paths. The two environments therefore need different Gradle settings.

## Approach — split into project-root common + user-level overlay

| File | Scope | Committed | Holds |
|---|---|---|---|
| `android/gradle.properties` | Cross-arch common | ✅ yes | AndroidX, build speed flags, heap, Kotlin incremental, R8 fullMode |
| `~/.gradle/gradle.properties` | Per-user overlay (per machine) | ❌ no | `org.gradle.java.home`, `-Djava.library.path`, `android.injected.build.abi` |

**Gradle precedence (verified Gradle 8.x)**: properties in `GRADLE_USER_HOME` (default `~/.gradle/`) **override** properties in the project root. So a missing `~/.gradle/gradle.properties` (CI) safely falls back to defaults, and a present one (local) injects host-specific settings.

## Local ARM (DGX Spark) — required overlay

Create or extend `~/.gradle/gradle.properties` with:

```properties
org.gradle.java.home=/usr/lib/jvm/java-21-openjdk-arm64
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError -Djava.library.path=/home/<user>/.local/lib:/lib/aarch64-linux-gnu
android.injected.build.abi=arm64-v8a
```

Adjust `/home/<user>/` to your actual path.

## CI X64 (ubuntu-latest)

No overlay. The workflow's `setup-java` step provides JAVA_HOME; the absence of `org.gradle.java.home` in committed properties means Gradle picks JAVA_HOME automatically. `android.injected.build.abi` is omitted, so CI builds the default universal ABI. The arm64-v8a ABI is also enforced separately by `android/app/build.gradle.kts:32` (`ndk { abiFilters += "arm64-v8a" }`) — so devices receive the right APK regardless of CI build config.

## Pre-build verification

```bash
flutter build apk --debug --target-platform=android-arm64
```

Local: succeeds in ~17s (cached) / ~60s (cold). CI: workflow handles its own.

If `gradle daemon` caches a stale `org.gradle.java.home` after overlay change:

```bash
cd android && ./gradlew --stop
```

## Known cosmetic warning

`Error initializing native libtinfo.so.5 (last dlerror is libtinfo.so.5: cannot open shared object file: No such file or directory)`

This is **cosmetic** — emitted by Gradle JVM banner but does not affect the build. Caused by Ubuntu 24.04 only providing `libtinfo.so.6`. Safe to ignore; tracked separately.

## v0.1.0 tag rot (Eng D1)

`v0.1.0` on remote `origin` points to `00fc35ae` (= `7e09180`), a commit that was severed from main history by `git filter-repo` on 2026-05-11 (see `project_github_reconciled_2026_05_11.md`). Current main HEAD is `8bc90a0`.

**Consequence**: if anyone pushes `v0.1.0` again (force), CI builds from severed history. If next tag (e.g. `v0.2.0`) is cut from main, GitHub's auto-generated release notes compare against the previous tag pointing into severed history → garbage or fail.

**Recommended resolution** (requires user decision — not auto-applied):

- **Option A** Delete `v0.1.0` everywhere; cut `v0.2.0` fresh from main:
  ```bash
  git tag -d v0.1.0
  git push origin :refs/tags/v0.1.0
  git tag v0.2.0
  git push origin v0.2.0
  ```
- **Option B** Move `v0.1.0` to current main (rewrite tag — destructive on shared remote):
  ```bash
  git tag -f v0.1.0 main
  git push origin v0.1.0 --force
  ```
- **Option C** Set `previous_tag` explicitly in `.github/workflows/release.yml` for next release.

Status as of 2026-05-12: **not applied**. Awaiting user decision.

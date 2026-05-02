# Issue tracker: Local Markdown

이슈와 PRD는 로컬 마크다운 파일로 `.scratch/` 아래에 보관한다.

## Conventions

- 한 feature당 한 디렉터리: `.scratch/<feature-slug>/`
- PRD 는 `.scratch/<feature-slug>/PRD.md`
- 구현 이슈는 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, `01` 부터 번호 매김
- 트리아지 상태는 각 이슈 파일 상단에 `Status:` 라인으로 기록 (`docs/agents/triage-labels.md` 참조)
- 댓글 / 대화 히스토리는 파일 하단 `## Comments` 섹션에 append

## Git tracking policy

`.scratch/` 는 **git 에 추적된다** (2026-05-03 결정).

- 이슈 히스토리, 트리아지 라벨 변경, 댓글이 모두 git history 에 보존됨
- `git clean` 또는 신규 clone 시 손실되지 않음
- 외부 공유 안 함 — 로컬 git 에만 보존
- 커밋 메시지 권장 prefix: `issue:` 또는 `triage:` (코드 커밋과 시각 분리). 작은 변경은 코드 커밋과 묶어도 됨.

## When a skill says "publish to the issue tracker"

`.scratch/<feature-slug>/` 아래 새 파일 생성 (디렉터리 없으면 함께 생성).

## When a skill says "fetch the relevant ticket"

참조된 경로의 파일을 읽는다. 사용자가 보통 경로 또는 이슈 번호를 직접 전달한다.

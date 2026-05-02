# Domain Docs

코드베이스를 탐색할 때 엔지니어링 스킬이 이 저장소의 도메인 문서를 어떻게 소비해야 하는지.

## Before exploring, read these

- 루트의 **`CONTEXT.md`**, 또는
- 루트의 **`CONTEXT-MAP.md`** (존재하면 — 컨텍스트별 `CONTEXT.md` 1개씩을 가리킴, 주제와 관련된 것을 모두 읽음)
- **`docs/adr/`** — 작업할 영역에 닿는 ADR 을 읽음. 멀티 컨텍스트 저장소에서는 `src/<context>/docs/adr/` 도 확인.

이 파일들이 존재하지 않으면 **silently 진행**한다. 부재를 사용자에게 알리지 말고, 사전 생성을 제안하지도 말 것. 프로듀서 스킬(`/grill-with-docs`)이 용어 또는 결정이 실제로 확정되는 시점에 lazy 하게 생성한다.

## File structure

이 저장소는 **단일 컨텍스트 저장소**이다.

```
/
├── CONTEXT.md                    ← lazy 생성 예정
├── docs/adr/                     ← lazy 생성 예정
│   ├── 0001-*.md
│   └── 0002-*.md
└── lib/                          ← Flutter 클라이언트
    ├── features/
    └── core/
```

## Use the glossary's vocabulary

도메인 개념을 이름 지을 때 (이슈 제목, 리팩토링 제안, 가설, 테스트 이름) `CONTEXT.md` 에 정의된 용어를 사용한다. 글로서리가 명시적으로 피하는 동의어로 표류하지 않는다.

필요한 개념이 글로서리에 아직 없다면 그것은 신호다 — 프로젝트가 사용하지 않는 언어를 발명하고 있거나(재고할 것), 진짜 갭이 있는 것(`/grill-with-docs` 호출 대상으로 메모).

## Flag ADR conflicts

출력이 기존 ADR 과 모순되면 silently 덮어쓰지 말고 명시적으로 surface 한다:

> _Contradicts ADR-0007 (event-sourced orders) — 다음 이유로 재오픈 가치 있음…_

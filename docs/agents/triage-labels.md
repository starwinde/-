# Triage Labels

스킬은 다섯 가지 표준 트리아지 역할로 말한다. 이 파일은 그 역할을 이 저장소의 실제 라벨 문자열에 매핑한다.

| Label in mattpocock/skills | Label in our tracker | Meaning                                            |
| -------------------------- | -------------------- | -------------------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer 가 평가해야 함                           |
| `needs-info`               | `needs-info`         | Reporter 의 추가 정보 대기 중                        |
| `ready-for-agent`          | `ready-for-agent`    | 완전히 명세됨, AFK 에이전트가 픽업 가능              |
| `ready-for-human`          | `ready-for-human`    | 사람이 직접 구현해야 함                              |
| `wontfix`                  | `wontfix`            | 처리하지 않음                                       |

스킬이 역할을 언급할 때 (예: "AFK-ready triage 라벨 적용"), 이 표의 우측 라벨 문자열을 사용한다.

이 저장소의 이슈 트래커는 로컬 마크다운(`docs/agents/issue-tracker.md` 참조)이므로, 라벨은 각 이슈 파일 상단의 `Status:` 라인 값으로 표현된다.

이 저장소의 실제 어휘에 맞게 우측 컬럼을 편집해도 된다. 현재는 기본값 그대로 사용 중이다.

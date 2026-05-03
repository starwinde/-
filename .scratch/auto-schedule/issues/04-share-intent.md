# 04 — Share intent 처리 (카톡 / 슬랙 메시지 → NLP)

Status: not-started

## 출처

Tasks.md `T5.12`.

## 설명

Android Share intent 수신 → 텍스트 추출 → 03 의 NLP 파이프라인 재사용 → 일정 등록.

## 작업

- [ ] `AndroidManifest.xml` Share intent filter 추가 (`text/plain`)
- [ ] Native → Flutter 채널로 텍스트 전달 (Pigeon)
- [ ] 03 의 `AutoScheduleService` 호출
- [ ] 결과 confirm UI (사용자가 일정 등록 확인 후 INSERT)

## 의존성

03 (Gmail NLP 파이프라인) 의 service 레이어 재사용. 03 이 in-progress 이지만 service 자체는 사용 가능.

## DoD

- 카카오톡 메시지 공유 → 일정 등록 다이얼로그 → 확정 → 주간 그리드 반영 (실기기)
- 회귀 0건

## Comments

(아직 없음)

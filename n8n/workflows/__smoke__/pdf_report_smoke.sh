#!/usr/bin/env bash
set -e
URL="https://localhost:5678/webhook/routinemon/pdf-report"
OUT="/tmp/routinemon-pdf-smoke.pdf"

echo "=== Case 1: 정상 weekly 리포트 → PDF ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  --output "$OUT" \
  -d '{
    "user_id":"u1",
    "period":"weekly",
    "report":{
      "summary":"이번 주 집중 세션 12회, 평균 78%로 좋은 흐름.",
      "insights":["오전 집중도가 가장 높습니다","수요일에 일정 누락이 잦았어요"],
      "suggestions":["수요일 알람을 30분 앞당겨 보세요","점심 직후 짧은 산책을 추가해 보세요"],
      "encouragement":"꾸준한 흐름이 멋져요!",
      "source":"llm"
    },
    "meta":{"pet_name":"두두","user_name":"민수","period_label":"4월 19일~25일"}
  }'
ls -l "$OUT"
head -c 5 "$OUT" | xxd | head -1
echo "(expect first 4 bytes: 25 50 44 46 = '%PDF')"

echo
echo "=== Case 2: 입력 누락 → 400 ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"u1"}' | python3 -m json.tool

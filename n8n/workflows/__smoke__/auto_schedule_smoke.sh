#!/usr/bin/env bash
set -e
URL="https://localhost:5678/webhook/routinemon/auto-schedule"

echo "=== Case 1: 정상 한국어 일정 (LLM 경로) ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"내일 오후 2시 팀 미팅","user_locale":"ko"}' | python3 -m json.tool

echo
echo "=== Case 2: 빈 텍스트 (preset fallback) ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"","user_locale":"ko"}' | python3 -m json.tool

echo
echo "=== Case 3: 차단어 (preset fallback) ==="
curl -sk -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"자살 생각이 들어","user_locale":"ko"}' | python3 -m json.tool

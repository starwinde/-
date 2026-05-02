// Content filter — n8n workflows 공용 로직.
// server.archived/src/middleware/content_filter.ts 이식 (rev 10, 2026-04-18).
// 각 워크플로우의 Code 노드에서 동일 상수·함수 복사 사용.
const PROFANITY_KO = ['바보', '멍청', '씨발', '개새끼', '지랄'];
const PROFANITY_EN = ['fuck', 'shit', 'asshole', 'idiot', 'bitch'];
const SELF_HARM = ['자해', '자살', '죽고 싶', 'kill myself', 'self harm', 'suicide'];

function filterContent(text) {
  const lower = (text || '').toLowerCase();
  for (const word of SELF_HARM) {
    if (lower.includes(word)) return { blocked: true, reason: 'self_harm' };
  }
  for (const word of [...PROFANITY_KO, ...PROFANITY_EN]) {
    if (lower.includes(word)) return { blocked: true, reason: 'profanity' };
  }
  return { blocked: false };
}

module.exports = { filterContent, PROFANITY_KO, PROFANITY_EN, SELF_HARM };

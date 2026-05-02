/// Validates pet names (1~10 chars, no banned words).
/// Pure Dart — no framework imports (rules.md 3.3).
class PetNameValidator {
  const PetNameValidator._();

  /// Shared banned word list for pet names and nicknames.
  static const bannedWords = [
    '바보',
    '멍청',
    '씨발',
    '시발',
    '병신',
    '개새끼',
    '죽어',
    'fuck',
    'shit',
    'damn',
    'ass',
    'dick',
  ];

  static bool isValid(String name) {
    if (name.isEmpty || name.length > 10) return false;
    final lower = name.toLowerCase();
    return !bannedWords.any(lower.contains);
  }
}

/// Validates user nicknames (2~12 chars, no banned words). PRD 2.13.
class NicknameValidator {
  const NicknameValidator._();

  static bool isValid(String nickname) {
    if (nickname.length < 2 || nickname.length > 12) return false;
    final lower = nickname.toLowerCase();
    return !PetNameValidator.bannedWords.any(lower.contains);
  }
}

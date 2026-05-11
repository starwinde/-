// RoleAnswerDraft persistence via SharedPreferences.
//
// 2026-05-12 Eng E1 fix. Wizard mid-flow should survive app kill.
// Stored as compact JSON under a single key.

import 'dart:convert';

import 'package:routinemon/features/schedule/domain/role_wizard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleWizardPersistence {
  RoleWizardPersistence(this._prefs);

  static const storageKey = 'role_wizard_draft';

  final SharedPreferences _prefs;

  Future<RoleAnswerDraft?> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      final roleName = json['role'];
      if (roleName is! String) return null;
      final role = Role.values.where((r) => r.name == roleName).firstOrNull;
      if (role == null) return null;
      final answersJson = json['answers'];
      if (answersJson is! Map) return null;
      final answers = <String, String>{};
      for (final entry in answersJson.entries) {
        final k = entry.key;
        final v = entry.value;
        if (k is String && v is String) {
          answers[k] = v;
        } else {
          return null;
        }
      }
      return RoleAnswerDraft(role: role, answers: Map.unmodifiable(answers));
    } on FormatException {
      return null;
    }
  }

  Future<void> save(RoleAnswerDraft draft) async {
    final json = jsonEncode({
      'role': draft.role.name,
      'answers': draft.answers,
    });
    await _prefs.setString(storageKey, json);
  }

  Future<void> clear() async {
    await _prefs.remove(storageKey);
  }
}

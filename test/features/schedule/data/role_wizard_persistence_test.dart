// Red: RoleAnswerDraft persistence — survives app kill mid-flow.
//
// 2026-05-12 Eng E1 fix. Uses SharedPreferences for simplicity (no Drift
// table needed for transient wizard draft).

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/role_wizard_persistence.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RoleWizardPersistence repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = RoleWizardPersistence(prefs);
  });

  test('load() returns null when nothing saved', () async {
    expect(await repo.load(), isNull);
  });

  test('save(draft) → load() returns the same draft', () async {
    final draft = const RoleAnswerDraft(role: Role.student)
        .setAnswer('class_window', 'morning')
        .setAnswer('exam_period', 'soon');
    await repo.save(draft);
    final loaded = await repo.load();
    expect(loaded, isNotNull);
    expect(loaded!.role, Role.student);
    expect(loaded.answers, {
      'class_window': 'morning',
      'exam_period': 'soon',
    });
  });

  test('save overwrites previous draft', () async {
    await repo.save(const RoleAnswerDraft(role: Role.student));
    await repo.save(
      const RoleAnswerDraft(role: Role.worker).setAnswer('work_form', 'shift'),
    );
    final loaded = await repo.load();
    expect(loaded!.role, Role.worker);
    expect(loaded.answers, {'work_form': 'shift'});
  });

  test('clear() removes stored draft', () async {
    await repo.save(const RoleAnswerDraft(role: Role.student));
    await repo.clear();
    expect(await repo.load(), isNull);
  });

  test('corrupted data → load returns null (graceful)', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(RoleWizardPersistence.storageKey, 'not-json{');
    expect(await repo.load(), isNull);
  });

  test('unknown role enum string → load returns null', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      RoleWizardPersistence.storageKey,
      '{"role":"alien","answers":{}}',
    );
    expect(await repo.load(), isNull);
  });
}

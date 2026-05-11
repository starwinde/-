// Widget tests for RoleWizardPage. Validates role tile rendering + question step.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';
import 'package:routinemon/features/schedule/presentation/role_wizard_page.dart';

void main() {
  Widget harness() {
    return const ProviderScope(
      child: MaterialApp(
        home: RoleWizardPage(),
      ),
    );
  }

  testWidgets('renders all 7 role tiles on step 0', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    for (final role in Role.values) {
      expect(find.text(role.displayLabel), findsOneWidget,
          reason: 'role tile for ${role.name}');
    }
  });

  testWidgets('tapping a role advances to first question', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('학생'));
    await tester.pumpAndSettle();

    final qs = questionsFor(Role.student);
    expect(find.text(qs.first.label), findsOneWidget);
  });

  testWidgets('selecting an option advances to next question', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('학생'));
    await tester.pumpAndSettle();

    final qs = questionsFor(Role.student);
    // First question — pick first option.
    await tester.tap(find.text(qs.first.options.first.label));
    await tester.pumpAndSettle();

    // Should advance to second question.
    expect(find.text(qs[1].label), findsOneWidget);
  });

  testWidgets('back button on question step returns to role selection',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('학생'));
    await tester.pumpAndSettle();

    // Back arrow in AppBar
    final backFinder = find.byTooltip('Back');
    if (backFinder.evaluate().isEmpty) {
      // Fallback: leading icon button.
      await tester.tap(find.byIcon(Icons.arrow_back));
    } else {
      await tester.tap(backFinder);
    }
    await tester.pumpAndSettle();

    // Should see role tile again.
    expect(find.text('학생'), findsOneWidget);
    expect(find.text('직장인'), findsOneWidget);
  });
}

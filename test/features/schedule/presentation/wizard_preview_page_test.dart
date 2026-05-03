import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/presentation/wizard_preview_page.dart';

void main() {
  group('WizardSourceChip', () {
    testWidgets('source=rule → "기본" 라벨', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardSourceChip(source: WizardSource.rule),
          ),
        ),
      );
      expect(find.text('기본'), findsOneWidget);
    });

    testWidgets('source=llm → "AI 향상" 라벨', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardSourceChip(source: WizardSource.llm),
          ),
        ),
      );
      expect(find.text('AI 향상'), findsOneWidget);
    });

    testWidgets('source=preset → "기본 (폴백)" 라벨', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardSourceChip(source: WizardSource.preset),
          ),
        ),
      );
      expect(find.text('기본 (폴백)'), findsOneWidget);
    });
  });

  group('WizardRefinementCounter', () {
    testWidgets('turnCount=2, maxTurns=5 → "재생성 2/5"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardRefinementCounter(turnCount: 2, maxTurns: 5),
          ),
        ),
      );
      expect(find.text('재생성 2/5'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('한도 도달'), findsNothing);
    });

    testWidgets('turnCount=5 → 한도 도달 + lock 아이콘', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardRefinementCounter(turnCount: 5, maxTurns: 5),
          ),
        ),
      );
      expect(find.text('재생성 5/5'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('한도 도달'), findsOneWidget);
    });
  });

  group('WizardDiffSummaryCard', () {
    testWidgets('summary 텍스트 + auto_awesome 아이콘', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardDiffSummaryCard(summary: '운동 슬롯 1개 추가됨'),
          ),
        ),
      );
      expect(find.text('운동 슬롯 1개 추가됨'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });

  group('WizardConflictsBanner', () {
    testWidgets('errCount=1, warnCount=2 → 정확한 텍스트', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardConflictsBanner(errCount: 1, warnCount: 2),
          ),
        ),
      );
      expect(find.text('충돌 3건 — error 1건 / warning 2건'), findsOneWidget);
    });

    testWidgets('errCount=0 → orange warning icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardConflictsBanner(errCount: 0, warnCount: 2),
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.color, Colors.orange);
    });

    testWidgets('errCount>0 → red error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardConflictsBanner(errCount: 2, warnCount: 0),
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.error));
      expect(icon.color, Colors.red);
    });
  });
}

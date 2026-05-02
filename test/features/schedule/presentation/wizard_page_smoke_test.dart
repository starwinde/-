import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/presentation/wizard_page.dart';

void main() {
  testWidgets(
    '첫 질문 "현재 직업/학업 상태는?" 확인',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WizardPage(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('주간 일정 만들기'), findsOneWidget);
      expect(find.textContaining('직업'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);
      expect(find.text('이전'), findsNothing);
    },
  );

  testWidgets(
    '다음 버튼 disabled-then-enabled after tapping 직장인',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WizardPage(),
          ),
        ),
      );
      await tester.pump();
      final nextBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '다음'),
      );
      expect(nextBtn.onPressed, isNull);

      await tester.tap(find.text('직장인'));
      await tester.pump();

      final nextBtn2 = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '다음'),
      );
      expect(nextBtn2.onPressed, isNotNull);
    },
  );
}

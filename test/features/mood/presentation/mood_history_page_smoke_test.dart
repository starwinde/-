import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/mood/presentation/mood_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('MoodHistoryPage renders empty state without crashing',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MoodHistoryPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('기분 기록'), findsOneWidget);
    expect(find.text('30일'), findsOneWidget);
  });
}

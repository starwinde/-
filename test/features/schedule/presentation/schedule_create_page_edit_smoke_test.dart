import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:routinemon/features/schedule/presentation/schedule_create_page.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('Create mode renders "일정 추가" title and "저장" button',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ScheduleCreatePage(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('일정 추가'), findsOneWidget);
    expect(find.text('저장'), findsOneWidget);
  });

  testWidgets(
      'Edit mode renders "일정 편집" title and "수정" button with scheduleId',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ScheduleCreatePage(scheduleId: 999),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('일정 편집'), findsOneWidget);
    expect(find.text('수정'), findsOneWidget);
  });
}

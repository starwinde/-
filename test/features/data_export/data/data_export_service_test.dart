import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/data_export/data/data_export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DataExportService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = DataExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('buildSnapshot returns empty arrays for new user', () async {
    final snap = await service.buildSnapshot('u1');
    expect(snap['schedules'], <dynamic>[]);
    expect(snap['sessions'], <dynamic>[]);
    expect(snap['pets'], <dynamic>[]);
    expect(snap['daily_scores'], <dynamic>[]);
    expect(snap['user_id'], 'u1');
    expect(snap['exported_at'], isA<String>());
  });

  test('exportAsJson returns parseable JSON', () async {
    final jsonStr = await service.exportAsJson('u1');
    final decoded = jsonDecode(jsonStr);
    expect(decoded, isA<Map<String, dynamic>>());
    expect((decoded as Map)['user_id'], 'u1');
  });

  test('hasQuota returns true initially, false after recordUsage', () async {
    expect(await service.hasQuota(), isTrue);
    await service.recordUsage();
    expect(await service.hasQuota(), isFalse);
  });

  test('hasQuota resets on new month', () async {
    await service.recordUsage();
    expect(await service.hasQuota(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('data_export_monthly_period');
    expect(await service.hasQuota(), isTrue);
  });
}

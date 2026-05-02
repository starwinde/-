import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/core/sync/outbox_sync_engine.dart';

// --- Mocks ---

class _MockRemoteSink extends Mock implements RemoteSink {}

void main() {
  late AppDatabase db;
  late _MockRemoteSink mockSink;
  late OutboxSyncEngine engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockSink = _MockRemoteSink();
    engine = OutboxSyncEngine(db, mockSink);

    // Fallback values for mocktail any() matchers.
    registerFallbackValue(<String, dynamic>{});
  });

  tearDown(() async {
    engine.stop();
    await db.close();
  });

  /// Helper: insert an outbox entry directly via Drift.
  Future<void> insertOutbox({
    required String targetTable,
    required String rowId,
    required String operation,
    String payload = '{}',
  }) async {
    await db.into(db.outbox).insert(
          OutboxCompanion.insert(
            targetTable: targetTable,
            rowId: rowId,
            operation: operation,
            payload: payload,
          ),
        );
  }

  group('OutboxSyncEngine.sync()', () {
    test('empty outbox returns synced=0', () async {
      final result = await engine.sync();

      expect(result.synced, 0);
      expect(result.failed, 0);
      expect(result.skipped, 0);
    });

    test('syncs 1 insert entry', () async {
      final data = {'id': 'r1', 'title': 'test'};
      await insertOutbox(
        targetTable: 'schedules',
        rowId: 'r1',
        operation: 'insert',
        payload: jsonEncode(data),
      );

      when(() => mockSink.insert('schedules', any()))
          .thenAnswer((_) async {});

      final result = await engine.sync();

      expect(result.synced, 1);
      expect(result.failed, 0);
      verify(() => mockSink.insert('schedules', data)).called(1);

      // Verify outbox row marked synced in DB
      final rows = await db.select(db.outbox).get();
      expect(rows.first.isSynced, true);
      expect(rows.first.syncedAt, isA<DateTime>());
    });

    test('syncs 3 entries', () async {
      for (var i = 1; i <= 3; i++) {
        await insertOutbox(
          targetTable: 'schedules',
          rowId: 'r$i',
          operation: 'insert',
          payload: jsonEncode({'id': 'r$i', 'title': 'item $i'}),
        );
      }

      when(() => mockSink.insert('schedules', any()))
          .thenAnswer((_) async {});

      final result = await engine.sync();

      expect(result.synced, 3);
      expect(result.failed, 0);
    });

    test('skips already synced entries', () async {
      await db.into(db.outbox).insert(
            OutboxCompanion.insert(
              targetTable: 'schedules',
              rowId: 'r1',
              operation: 'insert',
              payload: '{}',
            ),
          );
      await (db.update(db.outbox)..where((t) => t.rowId.equals('r1'))).write(
        OutboxCompanion(
          isSynced: const Value(true),
          syncedAt: Value(DateTime.now()),
        ),
      );

      final result = await engine.sync();

      expect(result.synced, 0);
      expect(result.failed, 0);
      expect(result.skipped, 0);
      verifyNever(() => mockSink.insert(any(), any()));
    });

    test('update operation uses upsert', () async {
      final data = {'id': 'r1', 'title': 'updated'};
      await insertOutbox(
        targetTable: 'schedules',
        rowId: 'r1',
        operation: 'update',
        payload: jsonEncode(data),
      );

      when(() => mockSink.upsert('schedules', any()))
          .thenAnswer((_) async {});

      final result = await engine.sync();

      expect(result.synced, 1);
      verify(() => mockSink.upsert('schedules', data)).called(1);
    });

    test('delete operation uses delete', () async {
      await insertOutbox(
        targetTable: 'schedules',
        rowId: 'r1',
        operation: 'delete',
      );

      when(() => mockSink.delete('schedules', 'r1'))
          .thenAnswer((_) async {});

      final result = await engine.sync();

      expect(result.synced, 1);
      verify(() => mockSink.delete('schedules', 'r1')).called(1);
    });

    test('Supabase failure increments failure count', () async {
      await insertOutbox(
        targetTable: 'schedules',
        rowId: 'r1',
        operation: 'insert',
        payload: '{"id": "r1"}',
      );

      when(() => mockSink.insert('schedules', any()))
          .thenThrow(Exception('network error'));

      final result = await engine.sync();

      expect(result.failed, 1);
      expect(result.synced, 0);

      // Outbox row should remain un-synced
      final rows = await db.select(db.outbox).get();
      expect(rows.first.isSynced, false);
    });

    test('skips entry after 3 consecutive failures', () async {
      await insertOutbox(
        targetTable: 'schedules',
        rowId: 'r1',
        operation: 'insert',
        payload: '{"id": "r1"}',
      );

      when(() => mockSink.insert('schedules', any()))
          .thenThrow(Exception('error'));

      // Fail 3 times
      for (var i = 0; i < 3; i++) {
        await engine.sync();
      }

      // 4th attempt should skip
      final result = await engine.sync();

      expect(result.skipped, 1);
      expect(result.failed, 0);
      expect(result.synced, 0);
    });

    test('mixed operations sync correctly', () async {
      await insertOutbox(
        targetTable: 'schedules',
        rowId: 'r1',
        operation: 'insert',
        payload: '{"id": "r1"}',
      );
      await insertOutbox(
        targetTable: 'pets',
        rowId: 'r2',
        operation: 'update',
        payload: '{"id": "r2", "name": "lumi"}',
      );
      await insertOutbox(
        targetTable: 'daily_scores',
        rowId: 'r3',
        operation: 'delete',
      );

      when(() => mockSink.insert('schedules', any()))
          .thenAnswer((_) async {});
      when(() => mockSink.upsert('pets', any()))
          .thenAnswer((_) async {});
      when(() => mockSink.delete('daily_scores', 'r3'))
          .thenAnswer((_) async {});

      final result = await engine.sync();

      expect(result.synced, 3);
      expect(result.failed, 0);
    });
  });
}

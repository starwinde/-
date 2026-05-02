import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/db/app_database.dart';
import 'package:routinemon/features/schedule/application/schedule_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'outbox_sync_engine.g.dart';

/// Abstracts remote table operations for testability.
abstract class RemoteSink {
  Future<void> insert(String table, Map<String, dynamic> data);
  Future<void> upsert(String table, Map<String, dynamic> data);
  Future<void> delete(String table, String rowId);
}

/// Production [RemoteSink] backed by Supabase.
class SupabaseRemoteSink implements RemoteSink {
  SupabaseRemoteSink(this._client);
  final SupabaseClient _client;

  @override
  Future<void> insert(String table, Map<String, dynamic> data) =>
      _client.from(table).insert(data);

  @override
  Future<void> upsert(String table, Map<String, dynamic> data) =>
      _client.from(table).upsert(data);

  @override
  Future<void> delete(String table, String rowId) =>
      _client.from(table).delete().eq('id', rowId);
}

/// 5-minute interval outbox sync engine.
/// LWW: server receive-time based (rules.md 3.7, PRD 2.12).
class OutboxSyncEngine {
  OutboxSyncEngine(this._db, this._sink);

  final AppDatabase _db;
  final RemoteSink _sink;
  Timer? _timer;

  /// Tracks consecutive failure counts per outbox row id (in-memory).
  /// Key = outbox table primary key (int id).
  final Map<int, int> _attempts = {};

  /// Max consecutive failures before skipping an entry.
  static const maxAttempts = 3;

  /// Starts 5-minute periodic sync. Safe to call multiple times.
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => sync());
  }

  /// Stops periodic sync.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Syncs all pending outbox entries to Supabase.
  Future<SyncResult> sync() async {
    // 1. Query un-synced outbox entries
    final pending = await (_db.select(_db.outbox)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    var synced = 0;
    var failed = 0;
    var skipped = 0;

    for (final entry in pending) {
      // Check attempts threshold
      final currentAttempts = _attempts[entry.id] ?? 0;
      if (currentAttempts >= maxAttempts) {
        skipped++;
        continue;
      }

      try {
        await _syncEntry(entry);

        // Mark synced in DB
        await (_db.update(_db.outbox)..where((t) => t.id.equals(entry.id)))
            .write(
          OutboxCompanion(
            isSynced: const Value(true),
            syncedAt: Value(DateTime.now()),
          ),
        );

        // Clear attempt counter on success
        _attempts.remove(entry.id);
        synced++;
      } catch (_) {
        _attempts[entry.id] = currentAttempts + 1;
        failed++;
      }
    }

    return SyncResult(synced: synced, failed: failed, skipped: skipped);
  }

  /// Dispatches a single outbox entry to the correct remote operation.
  Future<void> _syncEntry(OutboxData entry) async {
    final table = entry.targetTable;
    final data = jsonDecode(entry.payload) as Map<String, dynamic>;

    switch (entry.operation) {
      case 'insert':
        await _sink.insert(table, data);
      case 'update':
        await _sink.upsert(table, data);
      case 'delete':
        await _sink.delete(table, entry.rowId);
      default:
        throw ArgumentError('Unknown operation: ${entry.operation}');
    }
  }
}

/// Result of a single sync cycle.
class SyncResult {
  const SyncResult({
    required this.synced,
    required this.failed,
    required this.skipped,
  });

  final int synced;
  final int failed;
  final int skipped;
}

/// Provides a keepAlive [OutboxSyncEngine] singleton.
@Riverpod(keepAlive: true)
OutboxSyncEngine outboxSyncEngine(Ref ref) {
  final db = ref.read(appDatabaseProvider);
  final supabase = Supabase.instance.client;
  final engine = OutboxSyncEngine(db, SupabaseRemoteSink(supabase));
  ref.onDispose(engine.stop);
  return engine;
}

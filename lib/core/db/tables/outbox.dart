import 'package:drift/drift.dart';

/// Outbox table for Drift → Supabase sync (rules.md 3.7).
/// Each write operation enqueues a row here; the sync engine
/// drains pending entries every 5 minutes (PRD 2.12).
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()(); // target Supabase table
  TextColumn get rowId => text()(); // primary key of the changed row
  TextColumn get operation => text()(); // insert, update, delete
  TextColumn get payload => text()(); // JSON snapshot of the row
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

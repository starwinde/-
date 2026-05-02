import 'package:drift/drift.dart';

/// Focus session records (PRD 2.9, 2.4).
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text()();
  IntColumn get scheduleId => integer().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get plannedDurationMin =>
      integer().withDefault(const Constant(0))();
  IntColumn get actualFocusMin =>
      integer().withDefault(const Constant(0))();
  IntColumn get blacklistUsageMin =>
      integer().withDefault(const Constant(0))();
  RealColumn get focusRatio => real().nullable()();
  TextColumn get grade => text().nullable()(); // S, A, B, C, D
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

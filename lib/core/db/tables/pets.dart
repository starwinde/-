import 'package:drift/drift.dart';

class Pets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get species => text()(); // bird, dragon, dolphin
  TextColumn get name => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get hp => integer().withDefault(const Constant(100))();
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get diedAt => dateTime().nullable()();
  TextColumn get deathCause => text().nullable()();
}

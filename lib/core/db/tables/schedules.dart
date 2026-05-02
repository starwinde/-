import 'package:drift/drift.dart';

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get category => text()(); // work, study, hobby, health, etc
  TextColumn get tags =>
      text().withDefault(const Constant('[]'))(); // JSON array
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isTodo => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get allowDisruption =>
      boolean().withDefault(const Constant(false))();
  IntColumn get disruptionIntensity =>
      integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

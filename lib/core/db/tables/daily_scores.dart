import 'package:drift/drift.dart';

class DailyScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get focusRatio => real().withDefault(const Constant(0))();
  TextColumn get grade => text()(); // S, A, B, C, D
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  IntColumn get hpChange => integer().withDefault(const Constant(0))();
  IntColumn get totalFocusMinutes =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalBlacklistMinutes =>
      integer().withDefault(const Constant(0))();
  IntColumn get mood => integer().withDefault(const Constant(3))(); // 1~5
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:routinemon/core/db/tables/daily_scores.dart';
import 'package:routinemon/core/db/tables/outbox.dart';
import 'package:routinemon/core/db/tables/pets.dart';
import 'package:routinemon/core/db/tables/schedules.dart';
import 'package:routinemon/core/db/tables/sessions.dart';

part 'app_database.g.dart';

/// Single Drift database instance for 루틴몬.
/// Phase 2: 5 tables — Schedules, Pets, DailyScores, Outbox, Sessions.
@DriftDatabase(tables: [Schedules, Pets, DailyScores, Outbox, Sessions])
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device SQLite database named `routinemon`.
  AppDatabase() : super(_open());

  /// Constructor accepting an explicit executor (for in-memory testing).
  AppDatabase.forTesting(super.e);

  static QueryExecutor _open() => driftDatabase(name: 'routinemon');

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.addColumn(schedules, schedules.allowDisruption);
        await m.addColumn(schedules, schedules.disruptionIntensity);
      }
    },
  );
}

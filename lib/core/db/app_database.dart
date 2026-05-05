import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:routinemon/core/db/tables/daily_scores.dart';
import 'package:routinemon/core/db/tables/outbox.dart';
import 'package:routinemon/core/db/tables/pet_interactions.dart';
import 'package:routinemon/core/db/tables/pets.dart';
import 'package:routinemon/core/db/tables/schedules.dart';
import 'package:routinemon/core/db/tables/sessions.dart';
import 'package:routinemon/core/db/tables/usage_logs.dart';

part 'app_database.g.dart';

/// Single Drift database instance for 루틴몬.
/// v4 (2026-05-03): UsageLogs added (ADR 0004 — observe-only L0 + 모든 단계 사용 기록).
/// v5 (2026-05-05): PetInteractions added (PRD §2.6 — 먹이·쓰다듬·놀아주기).
@DriftDatabase(
  tables: [
    Schedules,
    Pets,
    DailyScores,
    Outbox,
    Sessions,
    UsageLogs,
    PetInteractions,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device SQLite database named `routinemon`.
  AppDatabase() : super(_open());

  /// Constructor accepting an explicit executor (for in-memory testing).
  AppDatabase.forTesting(super.e);

  static QueryExecutor _open() => driftDatabase(name: 'routinemon');

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.addColumn(schedules, schedules.allowDisruption);
        await m.addColumn(schedules, schedules.disruptionIntensity);
      }
      if (from < 4) {
        await m.createTable(usageLogs);
      }
      if (from < 5) {
        await m.createTable(petInteractions);
      }
    },
  );
}

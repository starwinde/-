/// Fixed schedule categories (PRD 2.8: 5 fixed categories).
/// Pure Dart — no framework imports (rules.md 3.3).
enum ScheduleCategory {
  work,
  study,
  hobby,
  health,
  etc;

  /// Converts a string value to [ScheduleCategory].
  /// Falls back to [etc] for unknown values.
  static ScheduleCategory fromString(String value) {
    return ScheduleCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScheduleCategory.etc,
    );
  }
}

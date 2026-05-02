import 'package:routinemon/core/native/usage_api.g.dart';

/// 블랙리스트 앱의 총 사용 시간(ms)을 계산하는 순수 함수.
/// domain layer — framework import 금지 (rules.md §3.3).
class BlacklistMatcher {
  const BlacklistMatcher._();

  /// [usageData]에서 [blacklist]에 포함된 패키지의
  /// totalTimeInForeground를 합산하여 반환.
  static int totalBlacklistUsage({
    required List<AppUsageInfo> usageData,
    required Set<String> blacklist,
  }) {
    var total = 0;
    for (final info in usageData) {
      if (blacklist.contains(info.packageName)) {
        total += info.totalTimeInForeground;
      }
    }
    return total;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/usage_api.g.dart';

part 'usage_bridge.g.dart';

/// Pigeon [UsageApi] 인스턴스를 제공하는 provider.
@riverpod
UsageApi usageApi(Ref ref) => UsageApi();

/// UsageStats 특수 권한 보유 여부를 반환하는 provider.
@riverpod
Future<bool> hasUsagePermission(Ref ref) async {
  final api = ref.watch(usageApiProvider);
  return api.hasUsagePermission();
}

/// 주어진 시간 범위의 앱 사용 통계를 조회하는 provider.
@riverpod
Future<List<AppUsageInfo>> queryUsageStats(
  Ref ref, {
  required int startTime,
  required int endTime,
}) async {
  final api = ref.watch(usageApiProvider);
  return api.queryUsageStats(startTime, endTime);
}

/// 설치된 패키지 목록을 반환하는 provider.
@riverpod
Future<List<String>> installedPackages(Ref ref) async {
  final api = ref.watch(usageApiProvider);
  return api.getInstalledPackages();
}

/// 현재 디바이스에서 `Intent.CATEGORY_HOME` 을 처리하는 모든 패키지 (런처).
/// 사용 통계 표시 시 distraction 통계에서 제외하는 데 사용. 결과는
/// keepAlive 캐시 — 사용자가 새 런처를 설치하기 전까지 안정적.
@Riverpod(keepAlive: true)
Future<Set<String>> launcherPackages(Ref ref) async {
  final api = ref.watch(usageApiProvider);
  try {
    final list = await api.getLauncherPackages();
    return list.toSet();
  } on Exception {
    return const <String>{};
  }
}

/// 패키지명 → 사람 표시명 캐시. UI 가 batch 로 lookup 후 결과 캐시.
@Riverpod(keepAlive: true)
class AppLabelCache extends _$AppLabelCache {
  final Map<String, String> _cache = {};

  @override
  Map<String, String> build() => _cache;

  /// 누락된 패키지만 native lookup → 캐시 채우고 반환.
  /// 미설치 패키지는 결과에 누락 — 호출자가 packageName 으로 fallback.
  Future<Map<String, String>> resolve(List<String> packages) async {
    final missing = packages.where((p) => !_cache.containsKey(p)).toList();
    if (missing.isNotEmpty) {
      final api = ref.read(usageApiProvider);
      try {
        final fetched = await api.getAppLabels(missing);
        _cache.addAll(fetched);
        // 미설치는 캐시에 packageName 자체로 마킹 — 재조회 방지.
        for (final p in missing) {
          _cache.putIfAbsent(p, () => p);
        }
        ref.notifyListeners();
      } on Exception {
        // swallow — UI 측 fallback
      }
    }
    return {for (final p in packages) p: _cache[p] ?? p};
  }
}

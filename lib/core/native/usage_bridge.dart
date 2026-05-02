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

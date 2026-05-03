import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/usage_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/starwinde/routinemon/UsageApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.starwinde.routinemon'),
  ),
)
class AppUsageInfo {
  AppUsageInfo({
    required this.packageName,
    required this.totalTimeInForeground,
  });
  String packageName;
  int totalTimeInForeground;
}

@HostApi()
abstract class UsageApi {
  bool hasUsagePermission();
  void openUsageSettings();
  List<AppUsageInfo> queryUsageStats(int startTime, int endTime);
  List<String> getInstalledPackages();

  /// 패키지명 → 사람이 읽을 수 있는 앱 라벨 매핑 (PackageManager.loadLabel).
  /// 미설치/시스템 패키지는 결과 Map 에서 누락 — UI 가 fallback 으로 packageName 사용.
  Map<String, String> getAppLabels(List<String> packages);
}

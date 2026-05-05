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

  /// `Intent.CATEGORY_HOME` 을 처리하는 모든 패키지 (기본 + 설치된 모든 런처).
  /// 사용 통계 표시 시 launcher 를 distraction 통계에서 제외하기 위함.
  /// OS 가 보장하는 contract — OEM/커스텀 런처 무관 자동 감지.
  List<String> getLauncherPackages();
}

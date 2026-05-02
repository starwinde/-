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
}

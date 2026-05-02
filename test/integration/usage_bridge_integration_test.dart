// T1.7 — UsageBridge 통합 테스트 (실기기 전용).
//
// integration_test 패키지가 pubspec에 없으므로 일반 test/로 배치하되
// 모든 테스트를 skip 처리합니다. 실기기 연결 후 아래 절차로 실행:
//
//   1. pubspec.yaml dev_dependencies에 추가:
//        integration_test:
//          sdk: flutter
//   2. 이 파일을 integration_test/ 디렉토리로 이동
//   3. skip: 주석 제거
//   4. flutter test integration_test/usage_bridge_integration_test.dart
//
// 또는 현재 위치에서 `flutter test test/integration/` 실행 시
// skip 표시로 PASS (0 skipped) 확인 가능.

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/native/usage_api.g.dart';

void main() {
  group('UsageBridge integration (실기기 전용)', () {
    late UsageApi api;

    setUp(() {
      api = UsageApi();
    });

    test(
      '권한 거부 상태에서 hasUsagePermission == false',
      skip: '실기기 연결 필요 — integration_test 패키지 추가 후 실행',
      () async {
        final hasPermission = await api.hasUsagePermission();
        expect(hasPermission, isFalse);
      },
    );

    test(
      '권한 허용 후 queryUsageStats 정상 반환',
      skip: '실기기 연결 필요 — 수동으로 권한 허용 후 실행',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final oneHourAgo = now - (60 * 60 * 1000);
        final result = await api.queryUsageStats(oneHourAgo, now);
        expect(result, isA<List<AppUsageInfo>>());
      },
    );

    test(
      'getInstalledPackages 비어있지 않음',
      skip: '실기기 연결 필요',
      () async {
        final packages = await api.getInstalledPackages();
        expect(packages, isNotEmpty);
      },
    );
  });
}

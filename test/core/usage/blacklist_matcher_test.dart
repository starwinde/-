import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/native/usage_api.g.dart';
import 'package:routinemon/core/usage/blacklist_matcher.dart';

void main() {
  group('BlacklistMatcher.totalBlacklistUsage', () {
    test('빈 usage + 빈 blacklist → 0', () {
      expect(
        BlacklistMatcher.totalBlacklistUsage(
          usageData: [],
          blacklist: {},
        ),
        0,
      );
    });

    test('usage 있고 blacklist 비어있음 → 0', () {
      expect(
        BlacklistMatcher.totalBlacklistUsage(
          usageData: [_info('com.app.a', 1000)],
          blacklist: {},
        ),
        0,
      );
    });

    test('1개 매칭 → 해당 시간', () {
      expect(
        BlacklistMatcher.totalBlacklistUsage(
          usageData: [
            _info('com.app.a', 1000),
            _info('com.app.b', 2000),
          ],
          blacklist: {'com.app.a'},
        ),
        1000,
      );
    });

    test('여러 매칭 → 합산', () {
      expect(
        BlacklistMatcher.totalBlacklistUsage(
          usageData: [
            _info('com.app.a', 1000),
            _info('com.app.b', 2000),
            _info('com.app.c', 3000),
          ],
          blacklist: {'com.app.a', 'com.app.c'},
        ),
        4000,
      );
    });

    test('동일 패키지 중복 항목 → 합산', () {
      expect(
        BlacklistMatcher.totalBlacklistUsage(
          usageData: [
            _info('com.app.a', 1000),
            _info('com.app.a', 500),
          ],
          blacklist: {'com.app.a'},
        ),
        1500,
      );
    });

    test('blacklist에 없는 패키지만 → 0', () {
      expect(
        BlacklistMatcher.totalBlacklistUsage(
          usageData: [
            _info('com.app.x', 5000),
            _info('com.app.y', 3000),
          ],
          blacklist: {'com.app.z'},
        ),
        0,
      );
    });
  });
}

AppUsageInfo _info(String pkg, int time) =>
    AppUsageInfo(packageName: pkg, totalTimeInForeground: time);

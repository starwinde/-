import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/constants/xp_rules.dart';

void main() {
  test('intimacyTierFor boundaries', () {
    expect(intimacyTierFor(0), 0);
    expect(intimacyTierFor(9), 0);
    expect(intimacyTierFor(10), 1);
    expect(intimacyTierFor(19), 1);
    expect(intimacyTierFor(20), 2);
    expect(intimacyTierFor(29), 2);
    expect(intimacyTierFor(30), 3);
    expect(intimacyTierFor(100), 3);
  });
  test('nextIntimacyThreshold', () {
    expect(nextIntimacyThreshold(0), 10);
    expect(nextIntimacyThreshold(9), 10);
    expect(nextIntimacyThreshold(10), 20);
    expect(nextIntimacyThreshold(20), 30);
    expect(nextIntimacyThreshold(30), null);
    expect(nextIntimacyThreshold(999), null);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/content/content_filter_types.dart';

void main() {
  group('ContentFilterReason', () {
    test('wire values match n8n shared module', () {
      expect(ContentFilterReason.selfHarm.wireValue, 'self_harm');
      expect(ContentFilterReason.profanity.wireValue, 'profanity');
      expect(ContentFilterReason.emptyText.wireValue, 'empty_text');
    });

    test('fromWire parses known values', () {
      expect(ContentFilterReason.fromWire('self_harm'),
          ContentFilterReason.selfHarm);
      expect(ContentFilterReason.fromWire('profanity'),
          ContentFilterReason.profanity);
      expect(ContentFilterReason.fromWire('empty_text'),
          ContentFilterReason.emptyText);
    });

    test('fromWire falls back to profanity for unknown', () {
      expect(ContentFilterReason.fromWire('xxx'),
          ContentFilterReason.profanity);
    });
  });
}

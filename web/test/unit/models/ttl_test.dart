import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/ttl.dart';

void main() {
  group('TTL Enum', () {
    test('has correct values', () {
      expect(TTL.values.length, equals(4));
      expect(TTL.values, contains(TTL.threeMonths));
      expect(TTL.values, contains(TTL.sixMonths));
      expect(TTL.values, contains(TTL.twelveMonths));
      expect(TTL.values, contains(TTL.never));
    });
  });
}

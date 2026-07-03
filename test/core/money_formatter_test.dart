import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/core/money_formatter.dart';

void main() {
  group('formatSom', () {
    test('zero has no separator', () {
      expect(formatSom(0), '0');
    });

    test('amounts under 1000 have no separator', () {
      expect(formatSom(7), '7');
      expect(formatSom(42), '42');
      expect(formatSom(999), '999');
    });

    test('the 999 -> 1000 boundary introduces exactly one separator', () {
      expect(formatSom(1000), '1 000');
    });

    test('inserts a separator every three digits from the right', () {
      expect(formatSom(90000), '90 000');
      expect(formatSom(100000), '100 000');
      expect(formatSom(1000000), '1 000 000');
    });

    test('handles a very large amount', () {
      expect(formatSom(1000000000), '1 000 000 000');
    });

    test('negative amounts are prefixed with a hyphen, digits unaffected', () {
      expect(formatSom(-90000), '-90 000');
      expect(formatSom(-7), '-7');
    });
  });

  group('formatSignedSom', () {
    test('positive amounts get an explicit + sign', () {
      expect(formatSignedSom(50000), '+50 000');
    });

    test('negative amounts keep the bare hyphen, no double sign', () {
      expect(formatSignedSom(-10000), '-10 000');
    });

    test('zero has no sign', () {
      expect(formatSignedSom(0), '0');
    });
  });
}

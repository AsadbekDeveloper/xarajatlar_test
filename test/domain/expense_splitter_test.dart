import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/features/ledger/domain/expense_splitter.dart';

void main() {
  group('splitEqually', () {
    test('sums to exactly the original amount for a range of amounts/participant counts', () {
      const amounts = [0, 1, 2, 3, 100, 999, 100000, 1000000000];
      for (final amount in amounts) {
        for (var participantCount = 1; participantCount <= 10; participantCount++) {
          final participantIds = List.generate(participantCount, (i) => 'p$i');
          final shares = splitEqually(amount, participantIds);

          expect(
            shares.values.fold(0, (sum, share) => sum + share),
            amount,
            reason: 'amount=$amount, n=$participantCount must not lose or gain a so\'m',
          );

          final maxShare = shares.values.reduce((a, b) => a > b ? a : b);
          final minShare = shares.values.reduce((a, b) => a < b ? a : b);
          expect(
            maxShare - minShare,
            lessThanOrEqualTo(1),
            reason: 'shares must differ by at most 1 so\'m',
          );
        }
      }
    });

    test('100 000 so\'m split 3 ways: two people get 33 334, one gets 33 333', () {
      final shares = splitEqually(100000, ['a', 'b', 'c']);
      expect(shares.values.toList(), [33334, 33333, 33333]);
      expect(shares.values.fold(0, (sum, share) => sum + share), 100000);
    });

    test('single participant receives the full amount', () {
      final shares = splitEqually(12345, ['solo']);
      expect(shares, {'solo': 12345});
    });

    test('remainder is given to the first participants in list order', () {
      final shares = splitEqually(10, ['a', 'b', 'c']);
      // base = 3, remainder = 1 -> only 'a' gets the extra so'm.
      expect(shares, {'a': 4, 'b': 3, 'c': 3});
    });
  });

  group('validateCustomShares', () {
    test('accepts shares that exactly cover the participants and sum to the amount', () {
      final error = validateCustomShares(100000, {'a': 60000, 'b': 40000}, ['a', 'b']);
      expect(error, isNull);
    });

    test('rejects a total that does not match the amount', () {
      final error = validateCustomShares(100000, {'a': 60000, 'b': 30000}, ['a', 'b']);
      expect(error, isNotNull);
    });

    test('rejects a negative share', () {
      final error = validateCustomShares(100000, {'a': 120000, 'b': -20000}, ['a', 'b']);
      expect(error, isNotNull);
    });

    test('rejects a share map missing a participant', () {
      final error = validateCustomShares(100000, {'a': 100000}, ['a', 'b']);
      expect(error, isNotNull);
    });
  });
}

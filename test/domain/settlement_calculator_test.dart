import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/features/ledger/domain/settlement_calculator.dart';

void main() {
  /// Every settlement list must itself be internally consistent: money paid
  /// out by each debtor equals their debt, money received by each creditor
  /// equals their credit, and nothing is invented or dropped.
  void expectSettlementsConserveBalances(
    Map<String, int> balances,
    List<Settlement> settlements,
  ) {
    final net = {for (final id in balances.keys) id: 0};
    for (final settlement in settlements) {
      net[settlement.fromId] = (net[settlement.fromId] ?? 0) - settlement.amount;
      net[settlement.toId] = (net[settlement.toId] ?? 0) + settlement.amount;
    }
    expect(net, balances);
  }

  test('reference mockup example settles in exactly the two payments shown in the design', () {
    final balances = {'aziz': 50000, 'bek': -10000, 'dilnoza': -40000};

    final settlements = calculateSettlements(balances);

    expect(settlements, [
      const Settlement(fromId: 'dilnoza', toId: 'aziz', amount: 40000),
      const Settlement(fromId: 'bek', toId: 'aziz', amount: 10000),
    ]);
    expectSettlementsConserveBalances(balances, settlements);
  });

  test('all-zero balances need no payments', () {
    final settlements = calculateSettlements({'a': 0, 'b': 0});
    expect(settlements, isEmpty);
  });

  test('empty balances need no payments', () {
    expect(calculateSettlements({}), isEmpty);
  });

  test('never exceeds n-1 transactions for n non-zero balances', () {
    final cases = [
      {'a': 100, 'b': -100},
      {'a': 300, 'b': -100, 'c': -100, 'd': -100},
      {'a': 60, 'b': 40, 'c': -30, 'd': -70},
      {'a': 8000, 'b': 5000, 'c': -2000, 'd': -2000, 'e': -5000, 'f': -4000},
    ];
    for (final balances in cases) {
      final settlements = calculateSettlements(balances);
      final nonZero = balances.values.where((v) => v != 0).length;
      expect(settlements.length, lessThanOrEqualTo(nonZero - 1));
      expectSettlementsConserveBalances(balances, settlements);
    }
  });

  test(
    'documented trade-off: the max-vs-max greedy heuristic is not always the '
    'global minimum (here it takes 5 payments; an exact solver could do it '
    'in 4 by cancelling C against E directly) — acceptable for a friend-group '
    'app since true global minimality is NP-hard to guarantee in general',
    () {
      final balances = {'a': -2000, 'b': -2000, 'c': -5000, 'd': 8000, 'e': 5000, 'f': -4000};

      final settlements = calculateSettlements(balances);

      expect(settlements.length, 5);
      expectSettlementsConserveBalances(balances, settlements);
    },
  );
}

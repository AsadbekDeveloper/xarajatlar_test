import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/features/ledger/domain/balance_calculator.dart';
import 'package:xarajatlar_test/features/ledger/domain/expense.dart';
import 'package:xarajatlar_test/features/ledger/domain/expense_splitter.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';

void main() {
  const aziz = Person(id: 'aziz', name: 'Aziz');
  const bek = Person(id: 'bek', name: 'Bek');
  const dilnoza = Person(id: 'dilnoza', name: 'Dilnoza');
  final people = [aziz, bek, dilnoza];

  Expense expense({
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
  }) => Expense(
    id: title,
    title: title,
    amount: amount,
    payerId: payerId,
    participantIds: participantIds,
    shares: splitEqually(amount, participantIds),
  );

  test(
    'the reference mockup scenario produces the exact expected balances',
    () {
      final expenses = [
        expense(
          title: 'Kechki ovqat',
          amount: 90000,
          payerId: aziz.id,
          participantIds: [aziz.id, bek.id, dilnoza.id],
        ),
        expense(
          title: 'Taksi',
          amount: 30000,
          payerId: bek.id,
          participantIds: [aziz.id, bek.id, dilnoza.id],
        ),
      ];

      final balances = calculateBalances(people, expenses);

      expect(balances[aziz.id], 50000);
      expect(balances[bek.id], -10000);
      expect(balances[dilnoza.id], -40000);
    },
  );

  test('balances always sum to exactly zero (conservation)', () {
    final expenses = [
      expense(
        title: 'a',
        amount: 100000,
        payerId: aziz.id,
        participantIds: [aziz.id, bek.id, dilnoza.id],
      ),
      expense(
        title: 'b',
        amount: 33333,
        payerId: dilnoza.id,
        participantIds: [bek.id, dilnoza.id],
      ),
      expense(
        title: 'c',
        amount: 1,
        payerId: bek.id,
        participantIds: [aziz.id],
      ),
    ];

    final balances = calculateBalances(people, expenses);

    expect(balances.values.fold(0, (sum, balance) => sum + balance), 0);
  });

  test('conservation holds even when the payer is not a participant', () {
    final expenses = [
      expense(
        title: 'office lunch',
        amount: 60000,
        payerId: aziz.id,
        participantIds: [bek.id, dilnoza.id],
      ),
    ];

    final balances = calculateBalances(people, expenses);

    expect(balances[aziz.id], 60000);
    expect(balances[bek.id], -30000);
    expect(balances[dilnoza.id], -30000);
    expect(balances.values.fold(0, (sum, balance) => sum + balance), 0);
  });

  test('a person with no expenses defaults to a zero balance', () {
    final balances = calculateBalances(people, const []);
    expect(balances, {aziz.id: 0, bek.id: 0, dilnoza.id: 0});
  });

  test('paying exactly your own share yields a zero balance', () {
    final expenses = [
      expense(
        title: 'solo coffee',
        amount: 15000,
        payerId: aziz.id,
        participantIds: [aziz.id],
      ),
    ];

    final balances = calculateBalances(people, expenses);

    expect(balances[aziz.id], 0);
  });
}

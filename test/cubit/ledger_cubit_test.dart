import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/features/ledger/cubit/ledger_cubit.dart';
import 'package:xarajatlar_test/features/ledger/data/in_memory_ledger_repository.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';

void main() {
  const aziz = Person(id: 'a', name: 'Aziz');
  const bek = Person(id: 'b', name: 'Bek');

  LedgerCubit buildCubit() =>
      LedgerCubit(InMemoryLedgerRepository(seedPeople: const [aziz, bek]));

  test('loads the seeded people immediately on construction', () {
    final cubit = buildCubit();
    expect(cubit.state.people, [aziz, bek]);
    expect(cubit.state.expenses, isEmpty);
  });

  test('addPerson returns the created person and updates state', () {
    final cubit = buildCubit();
    final person = cubit.addPerson('Dilnoza');

    expect(person.name, 'Dilnoza');
    expect(cubit.state.people, contains(person));
  });

  test('addExpense adds to state.expenses', () {
    final cubit = buildCubit();

    cubit.addExpense(
      title: 'lunch',
      amount: 10000,
      payerId: 'a',
      participantIds: ['a', 'b'],
    );

    expect(cubit.state.expenses, hasLength(1));
    expect(cubit.state.expenses.single.title, 'lunch');
  });

  test('updateExpense updates the matching expense in state', () {
    final cubit = buildCubit();
    cubit.addExpense(
      title: 'lunch',
      amount: 10000,
      payerId: 'a',
      participantIds: ['a', 'b'],
    );
    final id = cubit.state.expenses.single.id;

    cubit.updateExpense(
      id,
      title: 'dinner',
      amount: 20000,
      payerId: 'b',
      participantIds: ['a', 'b'],
    );

    final updated = cubit.state.expenses.single;
    expect(updated.title, 'dinner');
    expect(updated.amount, 20000);
    expect(updated.payerId, 'b');
  });

  test(
    'updateExpense with an unknown id propagates the error rather than swallowing it',
    () {
      final cubit = buildCubit();

      expect(
        () => cubit.updateExpense(
          'missing',
          title: 'x',
          amount: 1000,
          payerId: 'a',
          participantIds: ['a'],
        ),
        throwsStateError,
      );
    },
  );

  test('deleteExpense/restoreExpense thread the index through to state', () {
    final cubit = buildCubit();
    cubit.addExpense(
      title: 'a',
      amount: 1000,
      payerId: 'a',
      participantIds: ['a', 'b'],
    );
    cubit.addExpense(
      title: 'b',
      amount: 2000,
      payerId: 'a',
      participantIds: ['a', 'b'],
    );
    final first = cubit.state.expenses.first;

    final index = cubit.deleteExpense(first.id);
    expect(cubit.state.expenses.map((e) => e.title), ['b']);

    cubit.restoreExpense(first, index);
    expect(cubit.state.expenses.map((e) => e.title), ['a', 'b']);
  });

  test('does not emit after close (isClosed guard)', () async {
    final cubit = buildCubit();
    await cubit.close();

    expect(() => cubit.addPerson('Late'), returnsNormally);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/features/ledger/data/in_memory_ledger_repository.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';

void main() {
  late InMemoryLedgerRepository repository;
  late String aId;
  late String bId;

  setUp(() {
    repository = InMemoryLedgerRepository(
      seedPeople: const [Person(id: 'a', name: 'A'), Person(id: 'b', name: 'B')],
    );
    aId = 'a';
    bId = 'b';
  });

  test('restoreExpense is idempotent under a double-tapped undo', () {
    final expense = repository.addExpense(
      title: 'lunch',
      amount: 10000,
      payerId: aId,
      participantIds: [aId, bId],
    );
    final index = repository.deleteExpense(expense.id);

    repository.restoreExpense(expense, index);
    repository.restoreExpense(expense, index);

    expect(repository.getExpenses().where((e) => e.id == expense.id).length, 1);
  });

  test('deleteExpense then restoreExpense round-trips correctly', () {
    final expense = repository.addExpense(
      title: 'lunch',
      amount: 10000,
      payerId: aId,
      participantIds: [aId, bId],
    );
    final index = repository.deleteExpense(expense.id);
    expect(repository.getExpenses(), isEmpty);

    repository.restoreExpense(expense, index);
    expect(repository.getExpenses(), [expense]);
  });

  test('restoreExpense reinserts a middle item at its original position', () {
    final a = repository.addExpense(
      title: 'a',
      amount: 1000,
      payerId: aId,
      participantIds: [aId, bId],
    );
    final b = repository.addExpense(
      title: 'b',
      amount: 2000,
      payerId: aId,
      participantIds: [aId, bId],
    );
    final c = repository.addExpense(
      title: 'c',
      amount: 3000,
      payerId: aId,
      participantIds: [aId, bId],
    );

    final index = repository.deleteExpense(b.id);
    expect(repository.getExpenses(), [a, c]);

    repository.restoreExpense(b, index);

    expect(repository.getExpenses(), [a, b, c]);
  });

  test('updateExpense throws a clear error for an id that does not exist', () {
    expect(
      () => repository.updateExpense(
        'missing',
        title: 'lunch',
        amount: 10000,
        payerId: aId,
        participantIds: [aId, bId],
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('updateExpense preserves the id and applies every field via copyWith', () {
    final expense = repository.addExpense(
      title: 'lunch',
      amount: 10000,
      payerId: aId,
      participantIds: [aId, bId],
    );

    final updated = repository.updateExpense(
      expense.id,
      title: 'dinner',
      amount: 20000,
      payerId: bId,
      participantIds: [aId, bId],
    );

    expect(updated.id, expense.id);
    expect(updated.title, 'dinner');
    expect(updated.amount, 20000);
    expect(updated.payerId, bId);
    expect(updated.shares.values.fold(0, (sum, share) => sum + share), 20000);
    expect(repository.getExpenses(), [updated]);
  });
}

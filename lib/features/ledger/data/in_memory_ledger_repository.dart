import '../domain/expense.dart';
import '../domain/expense_splitter.dart';
import '../domain/person.dart';
import 'ledger_repository.dart';

class InMemoryLedgerRepository implements LedgerRepository {
  InMemoryLedgerRepository({List<Person>? seedPeople})
    : _people = List.of(seedPeople ?? _defaultSeedPeople);

  static const _defaultSeedPeople = [
    Person(id: 'p1', name: 'Aziz'),
    Person(id: 'p2', name: 'Bek'),
    Person(id: 'p3', name: 'Dilnoza'),
  ];

  final List<Person> _people;
  final List<Expense> _expenses = [];
  int _nextPersonId = 4;
  int _nextExpenseId = 1;

  @override
  List<Person> getPeople() => List.unmodifiable(_people);

  @override
  List<Expense> getExpenses() => List.unmodifiable(_expenses);

  @override
  Person addPerson(String name) {
    final person = Person(id: 'p${_nextPersonId++}', name: name);
    _people.add(person);
    return person;
  }

  @override
  Expense addExpense({
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
    Map<String, int>? customShares,
  }) {
    final expense = Expense(
      id: 'e${_nextExpenseId++}',
      title: title,
      amount: amount,
      payerId: payerId,
      participantIds: participantIds,
      shares: customShares ?? splitEqually(amount, participantIds),
    );
    _expenses.add(expense);
    return expense;
  }

  @override
  Expense updateExpense(
    String expenseId, {
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
    Map<String, int>? customShares,
  }) {
    final index = _expenses.indexWhere((expense) => expense.id == expenseId);
    if (index == -1) throw StateError('Expense $expenseId not found');
    final updated = _expenses[index].copyWith(
      title: title,
      amount: amount,
      payerId: payerId,
      participantIds: participantIds,
      shares: customShares ?? splitEqually(amount, participantIds),
    );
    _expenses[index] = updated;
    return updated;
  }

  @override
  int deleteExpense(String expenseId) {
    final index = _expenses.indexWhere((expense) => expense.id == expenseId);
    if (index != -1) _expenses.removeAt(index);
    return index;
  }

  @override
  void restoreExpense(Expense expense, int index) {
    // Idempotent: a double-tapped undo action must not duplicate the id.
    if (_expenses.any((existing) => existing.id == expense.id)) return;
    _expenses.insert(index.clamp(0, _expenses.length), expense);
  }
}

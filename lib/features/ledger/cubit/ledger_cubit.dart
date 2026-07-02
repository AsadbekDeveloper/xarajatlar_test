import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/ledger_repository.dart';
import '../domain/expense.dart';
import '../domain/person.dart';
import 'ledger_state.dart';

class LedgerCubit extends Cubit<LedgerState> {
  LedgerCubit(this._repository) : super(const LedgerState.initial()) {
    _refresh();
  }

  final LedgerRepository _repository;

  Person addPerson(String name) {
    final person = _repository.addPerson(name);
    _refresh();
    return person;
  }

  void addExpense({
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
    Map<String, int>? customShares,
  }) {
    _repository.addExpense(
      title: title,
      amount: amount,
      payerId: payerId,
      participantIds: participantIds,
      customShares: customShares,
    );
    _refresh();
  }

  void updateExpense(
    String expenseId, {
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
    Map<String, int>? customShares,
  }) {
    _repository.updateExpense(
      expenseId,
      title: title,
      amount: amount,
      payerId: payerId,
      participantIds: participantIds,
      customShares: customShares,
    );
    _refresh();
  }

  /// Returns the index the expense occupied, so the caller can pass it back
  /// to [restoreExpense] and put it back in the same place.
  int deleteExpense(String expenseId) {
    final index = _repository.deleteExpense(expenseId);
    _refresh();
    return index;
  }

  void restoreExpense(Expense expense, int index) {
    _repository.restoreExpense(expense, index);
    _refresh();
  }

  void _refresh() {
    if (isClosed) return;
    emit(
      LedgerState(
        people: _repository.getPeople(),
        expenses: _repository.getExpenses(),
      ),
    );
  }
}

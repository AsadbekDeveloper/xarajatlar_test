import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show listEquals;

import '../domain/expense.dart';
import '../domain/person.dart';

/// Holds only the source-of-truth lists. Balances and settlements are
/// derived values computed on demand (see `balance_calculator.dart` /
/// `settlement_calculator.dart`) rather than cached here, so there is a
/// single place that can go stale — nowhere.
class LedgerState extends Equatable {
  const LedgerState({required this.people, required this.expenses});

  const LedgerState.initial() : people = const [], expenses = const [];

  final List<Person> people;
  final List<Expense> expenses;

  Person personById(String id) => people.findById(id);

  LedgerState copyWith({List<Person>? people, List<Expense>? expenses}) =>
      LedgerState(
        people: people ?? this.people,
        expenses: expenses ?? this.expenses,
      );

  @override
  List<Object?> get props => [people, expenses];
}

/// `buildWhen`/`listenWhen` predicate: true if [curr].people differs from
/// [prev].people. Centralized here so every screen that reads people agrees
/// on what "changed" means.
bool ledgerPeopleChanged(LedgerState prev, LedgerState curr) =>
    !listEquals(prev.people, curr.people);

/// `buildWhen` predicate: true if either people or expenses changed.
bool ledgerDataChanged(LedgerState prev, LedgerState curr) =>
    ledgerPeopleChanged(prev, curr) ||
    !listEquals(prev.expenses, curr.expenses);

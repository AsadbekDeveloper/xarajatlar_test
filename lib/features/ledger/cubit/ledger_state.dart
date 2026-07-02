import 'package:equatable/equatable.dart';

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

  LedgerState copyWith({List<Person>? people, List<Expense>? expenses}) =>
      LedgerState(
        people: people ?? this.people,
        expenses: expenses ?? this.expenses,
      );

  @override
  List<Object?> get props => [people, expenses];
}

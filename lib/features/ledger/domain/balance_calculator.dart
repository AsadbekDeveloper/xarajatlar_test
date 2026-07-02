import 'expense.dart';
import 'person.dart';

/// Net balance per person: how much they paid minus how much they owe.
///
/// Every person is present in the result (defaulting to 0), including those
/// with no expenses. Summed across all people the result is always exactly
/// 0 — each expense's `amount` is added once (to the payer) and subtracted
/// once in total (spread across `shares`, which sums to `amount`) — so the
/// two contributions always cancel, even when the payer isn't one of the
/// expense's participants.
Map<String, int> calculateBalances(List<Person> people, List<Expense> expenses) {
  final balances = {for (final person in people) person.id: 0};
  for (final expense in expenses) {
    balances[expense.payerId] = (balances[expense.payerId] ?? 0) + expense.amount;
    for (final entry in expense.shares.entries) {
      balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
    }
  }
  return balances;
}

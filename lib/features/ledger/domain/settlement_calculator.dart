import 'package:equatable/equatable.dart';

class Settlement extends Equatable {
  const Settlement({
    required this.fromId,
    required this.toId,
    required this.amount,
  });

  /// Person who must pay.
  final String fromId;

  /// Person who receives the payment.
  final String toId;
  final int amount;

  @override
  List<Object?> get props => [fromId, toId, amount];
}

/// Minimum-transaction settlement: repeatedly pays the largest debtor to the
/// largest creditor. This never links every debtor to every creditor (the
/// naive O(n*m) approach the task calls out as wrong) and always produces at
/// most n-1 transactions for n people with a non-zero balance.
///
/// It is a well-known heuristic (used by apps like Splitwise), not a proof
/// of the global minimum — the true minimum-transaction problem is
/// NP-hard (equivalent to LeetCode 465 "Optimal Account Balancing") and
/// needs exponential backtracking to guarantee. See
/// `settlement_calculator_test.dart` for a documented case where this
/// heuristic and the true optimum differ.
List<Settlement> calculateSettlements(Map<String, int> balances) {
  // Mutable working copy so each step can re-find the current largest
  // creditor/debtor — a partially-settled balance can drop below another
  // untouched one, so the max must be re-picked every iteration rather than
  // fixed by a single upfront sort.
  final remaining = {
    for (final entry in balances.entries)
      if (entry.value != 0) entry.key: entry.value,
  };

  final settlements = <Settlement>[];
  while (remaining.isNotEmpty) {
    var creditorId = remaining.keys.first;
    var debtorId = remaining.keys.first;
    for (final entry in remaining.entries) {
      if (entry.value > remaining[creditorId]!) creditorId = entry.key;
      if (entry.value < remaining[debtorId]!) debtorId = entry.key;
    }

    final amount = remaining[creditorId]! < -remaining[debtorId]!
        ? remaining[creditorId]!
        : -remaining[debtorId]!;
    settlements.add(
      Settlement(fromId: debtorId, toId: creditorId, amount: amount),
    );

    remaining[creditorId] = remaining[creditorId]! - amount;
    remaining[debtorId] = remaining[debtorId]! + amount;
    if (remaining[creditorId] == 0) remaining.remove(creditorId);
    if (remaining[debtorId] == 0) remaining.remove(debtorId);
  }

  return settlements;
}

import 'package:equatable/equatable.dart';

/// A shared expense. [shares] is precomputed at creation time (either an
/// equal split or a validated custom split) and always sums to [amount] —
/// callers never re-derive it, so the invariant only needs proving once.
class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.participantIds,
    required this.shares,
  });

  final String id;
  final String title;
  final int amount;
  final String payerId;
  final List<String> participantIds;
  final Map<String, int> shares;

  Expense copyWith({
    String? title,
    int? amount,
    String? payerId,
    List<String>? participantIds,
    Map<String, int>? shares,
  }) => Expense(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    payerId: payerId ?? this.payerId,
    participantIds: participantIds ?? this.participantIds,
    shares: shares ?? this.shares,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    payerId,
    participantIds,
    shares,
  ];
}

/// Splits [amount] (whole so'm) equally across [participantIds].
///
/// Integer division always leaves a remainder smaller than the participant
/// count, so handing that remainder out one so'm at a time — to the first
/// [amount] % n participants, in list order — never loses or duplicates a
/// so'm: `base * n + remainder * 1 == (amount - remainder) + remainder ==
/// amount`, for any amount >= 0 and any non-empty participant list. Both
/// preconditions are enforced below: `~/`/`%` don't cancel out symmetrically
/// for a negative amount, which would otherwise silently break that
/// invariant instead of failing.
Map<String, int> splitEqually(int amount, List<String> participantIds) {
  if (participantIds.isEmpty) {
    throw ArgumentError.value(
      participantIds,
      'participantIds',
      'An expense needs at least one participant.',
    );
  }
  if (amount < 0) {
    throw ArgumentError.value(amount, 'amount', 'must be >= 0');
  }
  final base = amount ~/ participantIds.length;
  final remainder = amount % participantIds.length;
  return {
    for (var i = 0; i < participantIds.length; i++)
      participantIds[i]: base + (i < remainder ? 1 : 0),
  };
}

/// Validates a manually-entered ("custom") split: it must cover exactly the
/// given participants, contain no negative shares, and sum to exactly
/// [amount] — the same money-accuracy requirement as the equal split.
String? validateCustomShares(
  int amount,
  Map<String, int> shares,
  List<String> participantIds,
) {
  if (!_sameParticipants(shares.keys, participantIds)) {
    return "Har bir qatnashchi uchun ulush kiriting";
  }
  if (shares.values.any((share) => share < 0)) {
    return "Ulush manfiy bo'lishi mumkin emas";
  }
  final total = shares.values.fold(0, (sum, share) => sum + share);
  if (total != amount) {
    return "Ulushlar yig'indisi ($total) summaga ($amount) teng emas";
  }
  return null;
}

bool _sameParticipants(Iterable<String> a, Iterable<String> b) {
  final setA = a.toSet();
  final setB = b.toSet();
  return setA.length == a.length &&
      setA.length == setB.length &&
      setA.containsAll(setB);
}

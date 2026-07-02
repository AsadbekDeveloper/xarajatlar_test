import '../domain/expense.dart';
import '../domain/person.dart';

/// Owns the canonical, mutable list of people and expenses. Currently
/// in-memory only (no persistence required by the task) — kept behind this
/// interface so the cubit and UI never depend on that detail and a
/// persistent implementation could be swapped in later without touching
/// them.
///
/// Methods are synchronous and return values directly rather than a
/// `Result<T>`: in-memory list mutations cannot fail, so wrapping them would
/// be ceremony with no failure mode to express. User-input validation
/// (empty name, non-positive amount, empty participant set, bad custom
/// split) happens in the cubit/form layer instead.
abstract class LedgerRepository {
  List<Person> getPeople();

  List<Expense> getExpenses();

  Person addPerson(String name);

  Expense addExpense({
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
    Map<String, int>? customShares,
  });

  Expense updateExpense(
    String expenseId, {
    required String title,
    required int amount,
    required String payerId,
    required List<String> participantIds,
    Map<String, int>? customShares,
  });

  /// Removes the expense and returns the index it occupied, so a later
  /// [restoreExpense] can put it back in the same place.
  int deleteExpense(String expenseId);

  /// Re-adds a previously deleted expense verbatim (same id/shares) at
  /// [index] — backs the "Bekor qilish" (undo) action after a delete.
  void restoreExpense(Expense expense, int index);
}

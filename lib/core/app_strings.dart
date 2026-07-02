import 'money_formatter.dart';

/// Every user-visible piece of UI copy, in one place — per the project
/// convention of keeping strings const in one obvious spot until real l10n
/// (ARB) is worth adopting. Naming follows the ARB key convention
/// (`{featureName}{Action}`) so a future migration to `context.l10n.xxx` is a
/// mechanical rename, not a redesign.
///
/// Deliberately excluded: `expense_splitter.dart`'s `validateCustomShares`
/// error messages — the domain layer stays pure Dart with zero outward
/// dependencies, so it doesn't import this (UI-adjacent) class.
class AppStrings {
  const AppStrings._();

  // App shell
  static const appTitle = "Hisob bo'lishish";

  // Navigation
  static const expensesTitle = 'Xarajatlar';
  static const summaryTitle = 'Yakuniy hisob';

  // Xarajatlar screen
  static const addExpenseButton = "Xarajat qo'shish";
  static const expenseDeletedMessage = "Xarajat o'chirildi";
  static const undoAction = 'Bekor qilish';
  static const deleteTooltip = "O'chirish";
  static const emptyExpensesTitle = "Hozircha xarajat yo'q";
  static const emptyExpensesSubtitle = "Birinchi xarajatni qo'shing";

  static String expenseSubtitle(String payerName, int participantCount) =>
      "$payerName to'ladi · $participantCount kishi";

  // Yakuniy hisob screen
  static const balancePositiveLabel = 'oladi';
  static const balanceNegativeLabel = 'beradi';
  static const balanceZeroLabel = 'hisobi teng';
  static const settlementsSectionHeader = "TO'LOVLAR";
  static const settlementsEmptyMessage = 'Hammaning hisobi teng!';

  // Add/edit expense form
  static const editExpenseTitle = 'Xarajatni tahrirlash';
  static const titleFieldLabel = 'Nomi';
  static const amountFieldLabel = "Summa (so'm)";
  static const payerFieldLabel = "Kim to'ladi";
  static const participantsLabel = 'Qatnashchilar';
  static const equalSplitLabel = 'Teng';
  static const customSplitLabel = 'Maxsus';
  static const saveButton = 'Saqlash';
  static const newParticipantHint = 'Yangi ishtirokchi';
  static const addPersonTooltip = "Qo'shish";
  static const customSplitBalancedMessage = 'Ulushlar mos keldi';

  /// Shown both when submitting an edit on an already-deleted expense
  /// (defensive backstop) and when the sheet auto-dismisses because the
  /// expense being edited disappeared — same underlying event, one message.
  static const expenseNoLongerExists = "Bu xarajat allaqachon o'chirilgan";

  static String customSplitRemaining(int remaining) =>
      'Qoldiq: ${formatSom(remaining)}';

  // Validation errors
  static const titleRequiredError = 'Xarajat nomini kiriting';
  static const amountRequiredError = 'Summani kiriting';
  static const participantsRequiredError = 'Kamida bitta qatnashchi tanlang';
  static const payerRequiredError = "To'lovchini tanlang";
}

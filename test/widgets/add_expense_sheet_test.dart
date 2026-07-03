import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/core/app_strings.dart';
import 'package:xarajatlar_test/core/app_theme.dart';
import 'package:xarajatlar_test/features/ledger/cubit/ledger_cubit.dart';
import 'package:xarajatlar_test/features/ledger/data/in_memory_ledger_repository.dart';
import 'package:xarajatlar_test/features/ledger/domain/expense_splitter.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';
import 'package:xarajatlar_test/features/ledger/widgets/add_expense_sheet.dart';

void main() {
  const aziz = Person(id: 'a', name: 'Aziz');
  const bek = Person(id: 'b', name: 'Bek');
  const dilnoza = Person(id: 'd', name: 'Dilnoza');

  LedgerCubit buildCubit() => LedgerCubit(
    InMemoryLedgerRepository(seedPeople: const [aziz, bek, dilnoza]),
  );

  /// A host page that opens the sheet via the same public entry point
  /// production code uses ([AddExpenseSheet.show]), so popping behaves
  /// exactly as it does for real — a bare [AddExpenseSheet] with no route
  /// beneath it can't be popped the same way.
  Widget wrapApp(LedgerCubit cubit, {String? editExpenseId}) =>
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AddExpenseSheet.show(
                  context,
                  initialExpense: editExpenseId == null
                      ? null
                      : cubit.state.expenses.firstWhere(
                          (expense) => expense.id == editExpenseId,
                        ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the title-required error and does not create an expense', (
    tester,
  ) async {
    final cubit = buildCubit();
    await tester.pumpWidget(wrapApp(cubit));
    await openSheet(tester);

    await tester.tap(find.byKey(const Key('expenseSubmitButton')));
    await tester.pump();

    expect(find.text(AppStrings.titleRequiredError), findsOneWidget);
    expect(cubit.state.expenses, isEmpty);
  });

  testWidgets('shows the amount-required error when the amount is left blank', (
    tester,
  ) async {
    final cubit = buildCubit();
    await tester.pumpWidget(wrapApp(cubit));
    await openSheet(tester);

    await tester.enterText(find.byKey(const Key('expenseTitleField')), 'Lunch');
    await tester.tap(find.byKey(const Key('expenseSubmitButton')));
    await tester.pump();

    expect(find.text(AppStrings.amountRequiredError), findsOneWidget);
    expect(cubit.state.expenses, isEmpty);
  });

  testWidgets('shows the payer-required error when no payer has been chosen', (
    tester,
  ) async {
    final cubit = buildCubit();
    await tester.pumpWidget(wrapApp(cubit));
    await openSheet(tester);

    await tester.enterText(find.byKey(const Key('expenseTitleField')), 'Lunch');
    await tester.enterText(
      find.byKey(const Key('expenseAmountField')),
      '10000',
    );
    await tester.tap(find.byKey(const Key('expenseSubmitButton')));
    await tester.pump();

    expect(find.text(AppStrings.payerRequiredError), findsOneWidget);
    expect(cubit.state.expenses, isEmpty);
  });

  testWidgets(
    'shows the participants-required error when every participant is deselected',
    (tester) async {
      final cubit = buildCubit();
      await tester.pumpWidget(wrapApp(cubit));
      await openSheet(tester);

      await tester.enterText(
        find.byKey(const Key('expenseTitleField')),
        'Lunch',
      );
      await tester.enterText(
        find.byKey(const Key('expenseAmountField')),
        '10000',
      );
      for (final person in cubit.state.people) {
        await tester.tap(find.widgetWithText(FilterChip, person.name));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('expenseSubmitButton')));
      await tester.pump();

      expect(find.text(AppStrings.participantsRequiredError), findsOneWidget);
      expect(cubit.state.expenses, isEmpty);
    },
  );

  testWidgets(
    'shows a custom-split validation error when entered shares do not sum '
    'to the amount',
    (tester) async {
      final cubit = buildCubit();
      await tester.pumpWidget(wrapApp(cubit));
      await openSheet(tester);

      await tester.enterText(
        find.byKey(const Key('expenseTitleField')),
        'Lunch',
      );
      await tester.enterText(
        find.byKey(const Key('expenseAmountField')),
        '10000',
      );
      await tester.tap(find.byKey(const Key('expensePayerDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(aziz.name).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.customSplitLabel));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(ValueKey('customSplitField_${aziz.id}')),
        '1000',
      );
      await tester.pump();

      // The custom-split fields push the button below the sheet's visible
      // viewport in the test surface's default size.
      await tester.ensureVisible(find.byKey(const Key('expenseSubmitButton')));
      await tester.tap(find.byKey(const Key('expenseSubmitButton')));
      await tester.pump();

      // Only Aziz's field was touched, so Bek/Dilnoza default to 0 — compute
      // the expected message from the same validator rather than
      // hardcoding its exact wording.
      final participantIds = cubit.state.people.map((p) => p.id).toList();
      final expectedError = validateCustomShares(10000, {
        for (final id in participantIds) id: id == aziz.id ? 1000 : 0,
      }, participantIds);

      expect(find.text(expectedError!), findsOneWidget);
      expect(cubit.state.expenses, isEmpty);
    },
  );

  testWidgets(
    'auto-dismisses with expenseNoLongerExists when the expense being '
    'edited is deleted elsewhere while the sheet is open',
    (tester) async {
      final cubit = buildCubit();
      cubit.addExpense(
        title: 'Lunch',
        amount: 10000,
        payerId: aziz.id,
        participantIds: [aziz.id, bek.id],
      );
      final expense = cubit.state.expenses.single;

      await tester.pumpWidget(wrapApp(cubit, editExpenseId: expense.id));
      await openSheet(tester);
      expect(find.byType(AddExpenseSheet), findsOneWidget);

      cubit.deleteExpense(expense.id);
      await tester.pumpAndSettle();

      expect(find.byType(AddExpenseSheet), findsNothing);
      expect(find.text(AppStrings.expenseNoLongerExists), findsOneWidget);
    },
  );

  testWidgets(
    'seeds the custom split editor with the original per-person shares when '
    'editing an expense that was not split equally',
    (tester) async {
      final cubit = buildCubit();
      cubit.addExpense(
        title: 'Rent',
        amount: 10000,
        payerId: aziz.id,
        participantIds: [aziz.id, bek.id],
        customShares: {aziz.id: 7000, bek.id: 3000},
      );
      final expense = cubit.state.expenses.single;

      await tester.pumpWidget(wrapApp(cubit, editExpenseId: expense.id));
      await openSheet(tester);

      // The custom-split fields are visible without tapping the "Maxsus"
      // segment first — proof the sheet inferred custom mode on its own
      // from the stored (uneven) shares, not just defaulted to equal.
      final azizField = tester.widget<TextField>(
        find.byKey(ValueKey('customSplitField_${aziz.id}')),
      );
      final bekField = tester.widget<TextField>(
        find.byKey(ValueKey('customSplitField_${bek.id}')),
      );

      expect(azizField.controller!.text, '7000');
      expect(bekField.controller!.text, '3000');
    },
  );
}

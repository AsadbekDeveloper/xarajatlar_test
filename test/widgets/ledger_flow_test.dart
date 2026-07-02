import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/app.dart';
import 'package:xarajatlar_test/core/app_strings.dart';
import 'package:xarajatlar_test/features/ledger/ledger.dart';

/// Golden-path flows exercised manually via Playwright during development —
/// automated here so a future change can't silently regress them.
Future<void> _pumpLedgerApp(WidgetTester tester) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => LedgerCubit(InMemoryLedgerRepository()),
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _addExpense(
  WidgetTester tester, {
  required String title,
  required String amount,
  required String payerName,
}) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('expenseTitleField')), title);
  await tester.enterText(find.byKey(const Key('expenseAmountField')), amount);

  await tester.tap(find.byKey(const Key('expensePayerDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(payerName).last);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('expenseSubmitButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'adding an expense shows it in the list with the right subtitle/amount',
    (tester) async {
      await _pumpLedgerApp(tester);

      await _addExpense(
        tester,
        title: 'Kechki ovqat',
        amount: '90000',
        payerName: 'Aziz',
      );

      expect(find.text('Kechki ovqat'), findsOneWidget);
      expect(find.text(AppStrings.expenseSubtitle('Aziz', 3)), findsOneWidget);
      expect(find.text('90 000'), findsOneWidget);
    },
  );

  testWidgets('deleting an expense and tapping undo restores it', (
    tester,
  ) async {
    await _pumpLedgerApp(tester);
    await _addExpense(
      tester,
      title: 'Taksi',
      amount: '30000',
      payerName: 'Bek',
    );

    await tester.tap(find.byTooltip(AppStrings.deleteTooltip));
    await tester.pumpAndSettle();

    expect(find.text('Taksi'), findsNothing);
    expect(find.text(AppStrings.emptyExpensesTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.undoAction));
    await tester.pumpAndSettle();

    expect(find.text('Taksi'), findsOneWidget);
  });

  testWidgets('editing an expense updates the amount shown in the list', (
    tester,
  ) async {
    await _pumpLedgerApp(tester);
    await _addExpense(
      tester,
      title: 'Kechki ovqat',
      amount: '90000',
      payerName: 'Aziz',
    );

    await tester.tap(find.text('Kechki ovqat'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('expenseAmountField')),
      '50000',
    );
    await tester.tap(find.byKey(const Key('expenseSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('50 000'), findsOneWidget);
    expect(find.text('90 000'), findsNothing);
  });
}

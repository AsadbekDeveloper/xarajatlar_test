import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/core/app_strings.dart';
import 'package:xarajatlar_test/core/app_theme.dart';
import 'package:xarajatlar_test/features/ledger/cubit/ledger_cubit.dart';
import 'package:xarajatlar_test/features/ledger/data/in_memory_ledger_repository.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';
import 'package:xarajatlar_test/features/ledger/view/summary_view.dart';

void main() {
  const aziz = Person(id: 'a', name: 'Aziz');
  const bek = Person(id: 'b', name: 'Bek');
  const dilnoza = Person(id: 'd', name: 'Dilnoza');

  Widget wrap(LedgerCubit cubit) => BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: SummaryView()),
    ),
  );

  testWidgets(
    'a person who paid exactly their own share shows the required zero-balance state',
    (tester) async {
      final cubit = LedgerCubit(
        InMemoryLedgerRepository(seedPeople: const [aziz]),
      );
      cubit.addExpense(
        title: 'Solo coffee',
        amount: 15000,
        payerId: aziz.id,
        participantIds: [aziz.id],
      );

      await tester.pumpWidget(wrap(cubit));

      expect(find.text(AppStrings.balanceZeroLabel), findsOneWidget);
    },
  );

  testWidgets(
    'the reference mockup scenario renders the exact expected balances and settlements',
    (tester) async {
      final cubit = LedgerCubit(
        InMemoryLedgerRepository(seedPeople: const [aziz, bek, dilnoza]),
      );
      cubit.addExpense(
        title: 'Kechki ovqat',
        amount: 90000,
        payerId: aziz.id,
        participantIds: [aziz.id, bek.id, dilnoza.id],
      );
      cubit.addExpense(
        title: 'Taksi',
        amount: 30000,
        payerId: bek.id,
        participantIds: [aziz.id, bek.id, dilnoza.id],
      );

      await tester.pumpWidget(wrap(cubit));

      expect(find.text('+50 000'), findsOneWidget);
      expect(find.text('-10 000'), findsOneWidget);
      expect(find.text('-40 000'), findsOneWidget);
      expect(find.text(AppStrings.balancePositiveLabel), findsOneWidget);
      expect(find.text(AppStrings.balanceNegativeLabel), findsNWidgets(2));
      expect(find.textContaining('Dilnoza → Aziz'), findsOneWidget);
      expect(find.textContaining('Bek → Aziz'), findsOneWidget);
      expect(find.text('40 000'), findsOneWidget);
      expect(find.text('10 000'), findsOneWidget);
    },
  );

  testWidgets('a ledger with no expenses shows the settlements-empty message', (
    tester,
  ) async {
    final cubit = LedgerCubit(
      InMemoryLedgerRepository(seedPeople: const [aziz, bek]),
    );

    await tester.pumpWidget(wrap(cubit));

    expect(find.text(AppStrings.balanceZeroLabel), findsNWidgets(2));
    expect(find.text(AppStrings.settlementsEmptyMessage), findsOneWidget);
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/app.dart';
import 'package:xarajatlar_test/core/app_strings.dart';
import 'package:xarajatlar_test/features/ledger/ledger.dart';

void main() {
  testWidgets('shows the empty expenses state on first launch', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => LedgerCubit(InMemoryLedgerRepository()),
        child: const App(),
      ),
    );

    // AppStrings.expensesTitle appears twice by design: the card title and
    // the bottom nav label.
    expect(find.text(AppStrings.expensesTitle), findsNWidgets(2));
    expect(find.text(AppStrings.emptyExpensesTitle), findsOneWidget);
  });
}

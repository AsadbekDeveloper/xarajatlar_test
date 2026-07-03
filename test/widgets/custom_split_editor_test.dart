import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/core/app_strings.dart';
import 'package:xarajatlar_test/core/app_theme.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';
import 'package:xarajatlar_test/features/ledger/widgets/custom_split_editor.dart';

void main() {
  const personA = Person(id: 'a', name: 'A');
  const personB = Person(id: 'b', name: 'B');
  const personC = Person(id: 'c', name: 'C');

  Widget wrap(List<Person> participants) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: CustomSplitEditor(
        participants: participants,
        totalAmount: 10000,
        initialShares: const {'a': 5000, 'b': 5000},
        onChanged: (_) {},
      ),
    ),
  );

  String textOf(WidgetTester tester, Person person) {
    final field = tester.widget<TextField>(
      find.byKey(ValueKey('customSplitField_${person.id}')),
    );
    return field.controller!.text;
  }

  testWidgets(
    'seeds every participant from initialShares on first appearance',
    (tester) async {
      await tester.pumpWidget(wrap([personA, personB]));

      expect(textOf(tester, personA), '5000');
      expect(textOf(tester, personB), '5000');
    },
  );

  testWidgets(
    'a participant removed then re-added during the same session starts blank, '
    'not with their stale pre-edit value',
    (tester) async {
      await tester.pumpWidget(wrap([personA, personB]));
      expect(textOf(tester, personB), '5000');

      // Deselect B — its controller is disposed.
      await tester.pumpWidget(wrap([personA]));
      expect(find.byKey(const ValueKey('customSplitField_b')), findsNothing);

      // Reselect B within the same editing session.
      await tester.pumpWidget(wrap([personA, personB]));

      expect(textOf(tester, personB), isEmpty);
    },
  );

  testWidgets(
    'onChanged reports parsed shares for every participant, defaulting '
    'untouched fields to 0',
    (tester) async {
      Map<String, int>? lastShares;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: CustomSplitEditor(
              participants: const [personA, personB, personC],
              totalAmount: 9000,
              onChanged: (shares) => lastShares = shares,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('customSplitField_a')),
        '4000',
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('customSplitField_b')),
        '5000',
      );
      await tester.pump();

      expect(lastShares, {'a': 4000, 'b': 5000, 'c': 0});
    },
  );

  testWidgets(
    'the remaining message switches to the balanced message once entered '
    'shares sum to the total amount',
    (tester) async {
      await tester.pumpWidget(wrap([personA, personB]));

      // wrap() seeds both fields from initialShares at 5000 each, which
      // already sums to totalAmount (10000) — starts balanced.
      expect(find.text(AppStrings.customSplitBalancedMessage), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('customSplitField_a')),
        '3000',
      );
      await tester.pump();

      expect(find.text(AppStrings.customSplitRemaining(2000)), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('customSplitField_b')),
        '7000',
      );
      await tester.pump();

      expect(find.text(AppStrings.customSplitBalancedMessage), findsOneWidget);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/core/app_theme.dart';
import 'package:xarajatlar_test/features/ledger/domain/person.dart';
import 'package:xarajatlar_test/features/ledger/widgets/custom_split_editor.dart';

void main() {
  const personA = Person(id: 'a', name: 'A');
  const personB = Person(id: 'b', name: 'B');

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
}

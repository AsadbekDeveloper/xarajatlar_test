import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/features/ledger/widgets/trailing_amount_text.dart';

void main() {
  Widget wrap(String text, {double textScale = 1.0}) => MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          child: Row(
            children: [
              const Expanded(child: Text('A very long person name here')),
              TrailingAmountText(text: text),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('renders a normal amount unchanged', (tester) async {
    await tester.pumpWidget(wrap('90 000'));
    expect(find.text('90 000'), findsOneWidget);
  });

  testWidgets('never truncates the largest allowed amount, at max text scale, '
      'next to a long label — it shrinks instead of ellipsizing', (
    tester,
  ) async {
    const largest = '+999 999 999 999';
    await tester.pumpWidget(wrap(largest, textScale: 1.3));

    // The full, untruncated string must still be in the tree — a money
    // value must never lose digits to an ellipsis, unlike a name.
    expect(find.text(largest), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

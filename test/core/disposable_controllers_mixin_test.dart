import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xarajatlar_test/core/disposable_controllers_mixin.dart';

class _HarnessWidget extends StatefulWidget {
  const _HarnessWidget({required this.onReady});

  final ValueChanged<_HarnessState> onReady;

  @override
  State<_HarnessWidget> createState() => _HarnessState();
}

class _HarnessState extends State<_HarnessWidget>
    with DisposableControllersMixin<_HarnessWidget> {
  late final TextEditingController kept = manageController('kept');
  late final TextEditingController removedEarly = manageController('early');

  @override
  void initState() {
    super.initState();
    widget.onReady(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  // A disposed ChangeNotifier throws FlutterError from addListener (guarded
  // by an assert), so it doubles as an is-this-disposed probe without
  // needing to expose any extra state from the mixin itself.
  testWidgets(
    'every controller created via manageController is disposed on unmount',
    (tester) async {
      late _HarnessState state;
      await tester.pumpWidget(_HarnessWidget(onReady: (s) => state = s));
      final kept = state.kept;
      expect(() => kept.addListener(() {}), returnsNormally);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(() => kept.addListener(() {}), throwsFlutterError);
    },
  );

  testWidgets(
    'disposeController disposes immediately, and unmounting afterward does not double-dispose it',
    (tester) async {
      late _HarnessState state;
      await tester.pumpWidget(_HarnessWidget(onReady: (s) => state = s));
      final removedEarly = state.removedEarly;

      state.disposeController(removedEarly);
      expect(() => removedEarly.addListener(() {}), throwsFlutterError);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(tester.takeException(), isNull);
    },
  );
}

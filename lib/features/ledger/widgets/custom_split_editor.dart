import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/app_theme.dart';
import '../domain/person.dart';

/// Bonus "teng bo'lmagan bo'linish" (unequal split): one so'm field per
/// participant, with a running total vs. target so the user can see the
/// remainder before submitting.
class CustomSplitEditor extends StatefulWidget {
  const CustomSplitEditor({
    super.key,
    required this.participants,
    required this.totalAmount,
    required this.onChanged,
    this.initialShares,
  });

  final List<Person> participants;
  final int totalAmount;
  final ValueChanged<Map<String, int>> onChanged;
  final Map<String, int>? initialShares;

  @override
  State<CustomSplitEditor> createState() => _CustomSplitEditorState();
}

class _CustomSplitEditorState extends State<CustomSplitEditor> {
  final Map<String, TextEditingController> _controllers = {};

  /// Participants who've ever had a controller — so a participant seeds from
  /// [CustomSplitEditor.initialShares] only the first time, not again after
  /// being deselected and reselected.
  final Set<String> _everSeenIds = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant CustomSplitEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers() {
    final currentIds = widget.participants.map((person) => person.id).toSet();
    _controllers.removeWhere((id, controller) {
      final shouldRemove = !currentIds.contains(id);
      if (shouldRemove) controller.dispose();
      return shouldRemove;
    });
    for (final person in widget.participants) {
      _controllers.putIfAbsent(person.id, () {
        final initial = _everSeenIds.contains(person.id)
            ? null
            : widget.initialShares?[person.id];
        return TextEditingController(
          text: initial == null ? '' : initial.toString(),
        );
      });
      _everSeenIds.add(person.id);
    }
  }

  int get _enteredTotal => _controllers.values.fold(
    0,
    (sum, c) => sum + (int.tryParse(c.text) ?? 0),
  );

  void _emitChange() {
    widget.onChanged({
      for (final entry in _controllers.entries)
        entry.key: int.tryParse(entry.value.text) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final remaining = widget.totalAmount - _enteredTotal;
    final isBalanced = remaining == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final person in widget.participants)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    person.name,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: AppLayout.splitAmountFieldWidth,
                  child: TextField(
                    key: ValueKey('customSplitField_${person.id}'),
                    controller: _controllers[person.id],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '0',
                    ),
                    onChanged: (_) => setState(_emitChange),
                  ),
                ),
              ],
            ),
          ),
        Text(
          isBalanced
              ? AppStrings.customSplitBalancedMessage
              : AppStrings.customSplitRemaining(remaining),
          style: textTheme.bodySmall?.copyWith(
            color: isBalanced
                ? context.ledgerColors.positive
                : context.ledgerColors.negative,
          ),
        ),
      ],
    );
  }
}

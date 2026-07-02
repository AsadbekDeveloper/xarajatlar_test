import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/app_theme.dart';
import '../../../core/context_extensions.dart';
import '../cubit/ledger_cubit.dart';
import '../cubit/ledger_state.dart';
import '../domain/expense.dart';
import '../domain/expense_splitter.dart';
import '../domain/person.dart';
import 'custom_split_editor.dart';
import 'participant_selector.dart';

enum _SplitMode { equal, custom }

/// Single form for both adding and editing an expense — pass
/// [initialExpense] to edit; omit it to add.
class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key, this.initialExpense});

  final Expense? initialExpense;

  static Future<void> show(BuildContext context, {Expense? initialExpense}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => AddExpenseSheet(initialExpense: initialExpense),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late final _titleController = TextEditingController(text: widget.initialExpense?.title ?? '');
  late final _amountController = TextEditingController(
    text: widget.initialExpense == null ? '' : widget.initialExpense!.amount.toString(),
  );

  String? _payerId;
  late Set<String> _participantIds;
  late _SplitMode _splitMode;
  Map<String, int>? _customShares;
  String? _errorMessage;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExpense;
    _payerId = initial?.payerId;
    _participantIds =
        initial?.participantIds.toSet() ??
        context.read<LedgerCubit>().state.people.map((person) => person.id).toSet();
    _splitMode = initial != null && !_matchesEqualSplit(initial)
        ? _SplitMode.custom
        : _SplitMode.equal;
    _customShares = initial?.shares;
  }

  bool _matchesEqualSplit(Expense expense) =>
      mapEquals(splitEqually(expense.amount, expense.participantIds), expense.shares);

  bool _isBeingEdited(Expense expense) => expense.id == widget.initialExpense!.id;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _setError(String message) => setState(() => _errorMessage = message);

  void _submit(List<Person> people) {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text) ?? 0;
    final participantIds = _participantIds.toList();

    if (title.isEmpty) return _setError(AppStrings.titleRequiredError);
    if (amount <= 0) return _setError(AppStrings.amountRequiredError);
    if (participantIds.isEmpty) return _setError(AppStrings.participantsRequiredError);
    if (_payerId == null || !people.any((person) => person.id == _payerId)) {
      return _setError(AppStrings.payerRequiredError);
    }

    Map<String, int>? customShares;
    if (_splitMode == _SplitMode.custom) {
      customShares = {for (final id in participantIds) id: _customShares?[id] ?? 0};
      final error = validateCustomShares(amount, customShares, participantIds);
      if (error != null) return _setError(error);
    }

    final cubit = context.read<LedgerCubit>();
    if (_isEditing) {
      // The BlocConsumer listener below should always catch a
      // deleted-out-from-under-us expense first and close the sheet; this is
      // a defense-in-depth backstop so a repository invariant violation can
      // never crash a widget's onPressed.
      try {
        cubit.updateExpense(
          widget.initialExpense!.id,
          title: title,
          amount: amount,
          payerId: _payerId!,
          participantIds: participantIds,
          customShares: customShares,
        );
      } on StateError {
        context.showError(AppStrings.expenseNoLongerExists);
        return;
      }
    } else {
      cubit.addExpense(
        title: title,
        amount: amount,
        payerId: _payerId!,
        participantIds: participantIds,
        customShares: customShares,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BlocConsumer<LedgerCubit, LedgerState>(
        listenWhen: (prev, curr) => _isEditing && !curr.expenses.any(_isBeingEdited),
        listener: (context, state) {
          if (!context.mounted) return;
          context.showError(AppStrings.expenseNoLongerExists);
          Navigator.of(context).pop();
        },
        buildWhen: (prev, curr) => prev.people != curr.people,
        builder: (context, state) {
          final people = state.people;
          final selectedParticipants = people
              .where((person) => _participantIds.contains(person.id))
              .toList();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEditing ? AppStrings.editExpenseTitle : AppStrings.addExpenseButton,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ExpenseDetailsFields(
                    titleController: _titleController,
                    amountController: _amountController,
                    payerId: _payerId,
                    people: people,
                    onAmountChanged: () => setState(() {}),
                    onPayerChanged: (id) => setState(() => _payerId = id),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ParticipantsSection(
                    people: people,
                    selectedIds: _participantIds,
                    onSelectionChanged: (ids) => setState(() => _participantIds = ids),
                    onAddPerson: (name) {
                      final person = context.read<LedgerCubit>().addPerson(name);
                      setState(() => _participantIds = {..._participantIds, person.id});
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SplitModeSection(
                    splitMode: _splitMode,
                    onSplitModeChanged: (mode) => setState(() => _splitMode = mode),
                    participants: selectedParticipants,
                    totalAmount: int.tryParse(_amountController.text) ?? 0,
                    initialShares: _customShares,
                    onSharesChanged: (shares) => _customShares = shares,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: context.ledgerColors.negative),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    key: const Key('expenseSubmitButton'),
                    onPressed: () => _submit(people),
                    child: Text(_isEditing ? AppStrings.saveButton : AppStrings.addExpenseButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The "what / how much / who paid" trio — dumb props-in/callbacks-out, the
/// parent owns the controllers and payer selection.
class _ExpenseDetailsFields extends StatelessWidget {
  const _ExpenseDetailsFields({
    required this.titleController,
    required this.amountController,
    required this.payerId,
    required this.people,
    required this.onAmountChanged,
    required this.onPayerChanged,
  });

  final TextEditingController titleController;
  final TextEditingController amountController;
  final String? payerId;
  final List<Person> people;
  final VoidCallback onAmountChanged;
  final ValueChanged<String?> onPayerChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('expenseTitleField'),
          controller: titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: AppStrings.titleFieldLabel),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: const Key('expenseAmountField'),
          controller: amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: AppStrings.amountFieldLabel),
          onChanged: (_) => onAmountChanged(),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          key: const Key('expensePayerDropdown'),
          initialValue: payerId,
          decoration: const InputDecoration(labelText: AppStrings.payerFieldLabel),
          items: [
            for (final person in people) DropdownMenuItem(value: person.id, child: Text(person.name)),
          ],
          onChanged: onPayerChanged,
        ),
      ],
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  const _ParticipantsSection({
    required this.people,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onAddPerson,
  });

  final List<Person> people;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final ValueChanged<String> onAddPerson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.participantsLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ParticipantSelector(
          people: people,
          selectedIds: selectedIds,
          onSelectionChanged: onSelectionChanged,
          onAddPerson: onAddPerson,
        ),
      ],
    );
  }
}

/// The split-mode toggle and its dependent custom-split fields, kept
/// together since one directly controls the other's visibility.
class _SplitModeSection extends StatelessWidget {
  const _SplitModeSection({
    required this.splitMode,
    required this.onSplitModeChanged,
    required this.participants,
    required this.totalAmount,
    required this.initialShares,
    required this.onSharesChanged,
  });

  final _SplitMode splitMode;
  final ValueChanged<_SplitMode> onSplitModeChanged;
  final List<Person> participants;
  final int totalAmount;
  final Map<String, int>? initialShares;
  final ValueChanged<Map<String, int>> onSharesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<_SplitMode>(
          segments: const [
            ButtonSegment(value: _SplitMode.equal, label: Text(AppStrings.equalSplitLabel)),
            ButtonSegment(value: _SplitMode.custom, label: Text(AppStrings.customSplitLabel)),
          ],
          selected: {splitMode},
          onSelectionChanged: (selection) => onSplitModeChanged(selection.first),
        ),
        if (splitMode == _SplitMode.custom) ...[
          const SizedBox(height: AppSpacing.md),
          CustomSplitEditor(
            participants: participants,
            totalAmount: totalAmount,
            initialShares: initialShares,
            onChanged: onSharesChanged,
          ),
        ],
      ],
    );
  }
}

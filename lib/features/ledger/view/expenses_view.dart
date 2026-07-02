import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/context_extensions.dart';
import '../cubit/ledger_cubit.dart';
import '../cubit/ledger_state.dart';
import '../domain/expense.dart';
import '../domain/person.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/empty_expenses_placeholder.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/screen_card.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.expensesTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          const Expanded(child: _ExpenseList()),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () => AddExpenseSheet.show(context),
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addExpenseButton),
          ),
        ],
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LedgerCubit, LedgerState>(
      buildWhen: (prev, curr) =>
          prev.expenses != curr.expenses || prev.people != curr.people,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: state.expenses.isEmpty
              ? const EmptyExpensesPlaceholder(key: ValueKey('empty'))
              : ListView.separated(
                  key: const ValueKey('list'),
                  itemCount: state.expenses.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final expense = state.expenses[index];
                    final payerName = state.people
                        .findById(expense.payerId)
                        .name;
                    return ExpenseListItem(
                      title: expense.title,
                      payerName: payerName,
                      participantCount: expense.participantIds.length,
                      amount: expense.amount,
                      onTap: () => AddExpenseSheet.show(
                        context,
                        initialExpense: expense,
                      ),
                      onDelete: () => _deleteExpense(context, expense),
                    );
                  },
                ),
        );
      },
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) {
    final cubit = context.read<LedgerCubit>();
    final index = cubit.deleteExpense(expense.id);
    context.showSuccessToast(
      AppStrings.expenseDeletedMessage,
      action: SnackBarAction(
        label: AppStrings.undoAction,
        onPressed: () => cubit.restoreExpense(expense, index),
      ),
    );
  }
}

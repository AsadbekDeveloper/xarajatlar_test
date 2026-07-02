import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../cubit/ledger_cubit.dart';
import '../cubit/ledger_state.dart';
import '../domain/balance_calculator.dart';
import '../domain/person.dart';
import '../domain/settlement_calculator.dart';
import '../widgets/person_balance_tile.dart';
import '../widgets/screen_card.dart';
import '../widgets/settlement_tile.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.summaryTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          const Expanded(child: _SummaryList()),
        ],
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  const _SummaryList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LedgerCubit, LedgerState>(
      buildWhen: (prev, curr) =>
          prev.expenses != curr.expenses || prev.people != curr.people,
      builder: (context, state) {
        final balances = calculateBalances(state.people, state.expenses);
        final settlements = calculateSettlements(balances);
        final textTheme = Theme.of(context).textTheme;

        return ListView(
          children: [
            for (final person in state.people)
              PersonBalanceTile(
                name: person.name,
                balance: balances[person.id] ?? 0,
              ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                AppStrings.settlementsSectionHeader,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (settlements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  AppStrings.settlementsEmptyMessage,
                  style: textTheme.bodyMedium,
                ),
              )
            else
              for (final settlement in settlements)
                SettlementTile(
                  fromName: state.people.findById(settlement.fromId).name,
                  toName: state.people.findById(settlement.toId).name,
                  amount: settlement.amount,
                ),
          ],
        );
      },
    );
  }
}

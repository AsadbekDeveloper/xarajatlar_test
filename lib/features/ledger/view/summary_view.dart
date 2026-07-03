import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../cubit/ledger_cubit.dart';
import '../cubit/ledger_state.dart';
import '../domain/balance_calculator.dart';
import '../domain/settlement_calculator.dart';
import '../widgets/person_balance_tile.dart';
import '../widgets/screen_card.dart';
import '../widgets/settlement_tile.dart';
import '../widgets/tinted_container.dart';

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
      buildWhen: ledgerDataChanged,
      builder: (context, state) {
        final balances = calculateBalances(state.people, state.expenses);
        final settlements = calculateSettlements(balances);

        return ListView(
          children: [
            _BalancesPanel(
              people: [
                for (final person in state.people)
                  (name: person.name, balance: balances[person.id] ?? 0),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettlementsSection(
              settlements: [
                for (final settlement in settlements)
                  (
                    fromName: state.personById(settlement.fromId).name,
                    toName: state.personById(settlement.toId).name,
                    amount: settlement.amount,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BalancesPanel extends StatelessWidget {
  const _BalancesPanel({required this.people});

  final List<({String name, int balance})> people;

  @override
  Widget build(BuildContext context) => TintedContainer(
    child: Column(
      children: [
        for (var i = 0; i < people.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const Divider(height: 1, color: Colors.black12),
            ),
          PersonBalanceTile(name: people[i].name, balance: people[i].balance),
        ],
      ],
    ),
  );
}

class _SettlementsSection extends StatelessWidget {
  const _SettlementsSection({required this.settlements});

  final List<({String fromName, String toName, int amount})> settlements;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.settlementsSectionHeader,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (settlements.isEmpty)
          Text(AppStrings.settlementsEmptyMessage, style: textTheme.bodyMedium)
        else
          for (var i = 0; i < settlements.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            TintedContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SettlementTile(
                fromName: settlements[i].fromName,
                toName: settlements[i].toName,
                amount: settlements[i].amount,
              ),
            ),
          ],
      ],
    );
  }
}

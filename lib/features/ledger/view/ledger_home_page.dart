import 'package:flutter/material.dart';

import '../../../core/app_strings.dart';
import 'expenses_view.dart';
import 'summary_view.dart';

class LedgerHomePage extends StatefulWidget {
  const LedgerHomePage({super.key});

  @override
  State<LedgerHomePage> createState() => _LedgerHomePageState();
}

class _LedgerHomePageState extends State<LedgerHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [ExpensesView(), SummaryView()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: AppStrings.expensesTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: AppStrings.summaryTitle,
          ),
        ],
      ),
    );
  }
}

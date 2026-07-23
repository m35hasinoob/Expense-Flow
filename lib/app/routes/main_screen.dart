import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/features/dashboard/presentation/dashboard_page.dart';
import 'package:expense_flow/features/history/presentation/history_page.dart';
import 'package:expense_flow/features/reports/presentation/reports_page.dart';
import 'package:expense_flow/features/settings/presentation/settings_page.dart';
import 'package:expense_flow/features/expense/presentation/add_expense_bottom_sheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardPage(),
    const HistoryPage(),
    const ReportsPage(),
    const SettingsPage(),
  ];

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddExpenseBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.history),
            selectedIcon: Icon(LucideIcons.history, color: AppColors.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.pieChart),
            selectedIcon: Icon(LucideIcons.pieChart, color: AppColors.primary),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            selectedIcon: Icon(LucideIcons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Expense'),
      )
          : null,
    );
  }
}
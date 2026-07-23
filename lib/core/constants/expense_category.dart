import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_colors.dart';

enum ExpenseCategory {
  morning('Morning', LucideIcons.sun, AppColors.morning),
  lunch('Lunch', LucideIcons.utensils, AppColors.lunch),
  dinner('Dinner', LucideIcons.moon, AppColors.dinner),
  others('Others', LucideIcons.moreHorizontal, AppColors.others);

  final String label;
  final IconData icon;
  final Color color;

  const ExpenseCategory(this.label, this.icon, this.color);

  
  static ExpenseCategory fromString(String category) {
    return ExpenseCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == category.toLowerCase(),
      orElse: () => ExpenseCategory.others,
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_flow/core/constants/expense_category.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart';


final categoryTotalsProvider = Provider<Map<ExpenseCategory, double>>((ref) {
  final expenseAsync = ref.watch(expenseProvider);

  return expenseAsync.maybeWhen(
    data: (expenses) {
      final Map<ExpenseCategory, double> totals = {
        for (var category in ExpenseCategory.values) category: 0.0,
      };

      for (var expense in expenses) {
        totals[expense.category] = (totals[expense.category] ?? 0.0) + expense.amount;
      }
      return totals;
    },
    orElse: () => {for (var category in ExpenseCategory.values) category: 0.0},
  );
});


class DaySpending {
  final DateTime date;
  final double amount;
  final String dayName;

  DaySpending({required this.date, required this.amount, required this.dayName});
}

final last7DaysSpendingProvider = Provider<List<DaySpending>>((ref) {
  final expenseAsync = ref.watch(expenseProvider);
  final now = DateTime.now();

  return expenseAsync.maybeWhen(
    data: (expenses) {
      final List<DaySpending> result = [];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayExpenses = expenses.where((e) {
          return e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day;
        });

        final dayTotal = dayExpenses.fold(0.0, (sum, item) => sum + item.amount);
        final dayName = _getDayName(date.weekday);

        result.add(DaySpending(date: date, amount: dayTotal, dayName: dayName));
      }

      return result;
    },
    orElse: () => [],
  );
});


String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
  }
}


final highestCategoryProvider = Provider<ExpenseCategory?>((ref) {
  final categoryTotals = ref.watch(categoryTotalsProvider);
  ExpenseCategory? highestCat;
  double maxAmount = 0.0;

  categoryTotals.forEach((cat, amount) {
    if (amount > maxAmount) {
      maxAmount = amount;
      highestCat = cat;
    }
  });

  return maxAmount > 0 ? highestCat : null;
});


final averageDailyExpenseProvider = Provider<double>((ref) {
  final last7Days = ref.watch(last7DaysSpendingProvider);
  if (last7Days.isEmpty) return 0.0;

  final total = last7Days.fold(0.0, (sum, day) => sum + day.amount);
  return total / 7;
});


final currentMonthTotalExpenseProvider = Provider<double>((ref) {
  final expenseAsync = ref.watch(expenseProvider);
  final now = DateTime.now();

  return expenseAsync.maybeWhen(
    data: (expenses) {
      return expenses.where((e) {
        return e.date.year == now.year && e.date.month == now.month;
      }).fold(0.0, (sum, item) => sum + item.amount);
    },
    orElse: () => 0.0,
  );
});


final currentYearTotalExpenseProvider = Provider<double>((ref) {
  final expenseAsync = ref.watch(expenseProvider);
  final now = DateTime.now();

  return expenseAsync.maybeWhen(
    data: (expenses) {
      return expenses.where((e) {
        return e.date.year == now.year;
      }).fold(0.0, (sum, item) => sum + item.amount);
    },
    orElse: () => 0.0,
  );
});
import 'package:intl/intl.dart';

abstract class AppFormatters {
  AppFormatters._();

  
  static String formatCurrency(double amount, {String symbol = 'BDT'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(amount)} $symbol';
  }

  
  static String formatCompactCurrency(double amount) {
    final formatter = NumberFormat.compact();
    return formatter.format(amount);
  }

  
  static String formatDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
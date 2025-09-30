import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
import 'package:intl/intl.dart';

abstract final class Formatters {
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _date = DateFormat('dd MMM yyyy');

  static String currency(double amount, {String currencyCode = 'INR'}) {
    return NumberFormat.simpleCurrency(
      locale: 'en_IN',
      name: currencyCode,
      decimalDigits: 2,
    ).format(amount);
  }

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String date(DateTime value) => _date.format(value);

  static String initials(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}

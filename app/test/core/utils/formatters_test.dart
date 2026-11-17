import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/core/utils/formatters.dart';

void main() {
  test('currency formats INR with Indian grouping', () {
    expect(Formatters.currency(25450.75), '₹25,450.75');
    expect(Formatters.currency(1500), '₹1,500.00');
    expect(Formatters.currency(1234567.5), '₹12,34,567.50');
  });

  test('dateTime formats date and time', () {
    expect(
      Formatters.dateTime(DateTime(2026, 10, 20, 15, 5)),
      '20 Oct 2026, 03:05 PM',
    );
  });

  test('initials uses the first letters of up to two words', () {
    expect(Formatters.initials('Demo User'), 'DU');
    expect(Formatters.initials('  rahul  '), 'R');
    expect(Formatters.initials('Ram Kumar Sharma'), 'RK');
  });
}

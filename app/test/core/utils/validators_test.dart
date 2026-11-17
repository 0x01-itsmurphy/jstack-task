import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('requires a value', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email('   '), 'Email is required');
    });

    test('rejects malformed addresses', () {
      for (final value in ['demo', 'demo@', 'demo@jstack', '@jstack.co']) {
        expect(Validators.email(value), 'Enter a valid email address');
      }
    });

    test('accepts a valid address with surrounding spaces', () {
      expect(Validators.email(' demo@jstack.co '), isNull);
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects short passwords', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters',
      );
    });

    test('accepts a valid password', () {
      expect(Validators.password('Demo@123'), isNull);
    });
  });

  group('Validators.beneficiaryName', () {
    test('requires a non-blank name', () {
      expect(Validators.beneficiaryName(''), 'Beneficiary name is required');
      expect(Validators.beneficiaryName('   '), 'Beneficiary name is required');
      expect(Validators.beneficiaryName('Rahul Sharma'), isNull);
    });
  });

  group('Validators.mobileNumber', () {
    test('requires a value', () {
      expect(Validators.mobileNumber(''), 'Mobile number is required');
    });

    test('rejects numbers that are not valid 10-digit mobiles', () {
      for (final value in [
        '98765',
        '98765432101',
        '5876543210',
        '98765abcde',
      ]) {
        expect(
          Validators.mobileNumber(value),
          'Enter a valid 10-digit mobile number',
        );
      }
    });

    test('accepts a valid mobile number', () {
      expect(Validators.mobileNumber('9876543210'), isNull);
    });
  });

  group('Validators.amount', () {
    test('requires a value', () {
      expect(Validators.amount(''), 'Amount is required');
    });

    test('rejects non-numeric input', () {
      expect(Validators.amount('abc'), 'Enter a valid amount');
      expect(Validators.amount('1.2.3'), 'Enter a valid amount');
    });

    test('rejects zero and negative amounts', () {
      expect(Validators.amount('0'), 'Amount must be greater than zero');
      expect(Validators.amount('0.00'), 'Amount must be greater than zero');
      expect(Validators.amount('-50'), 'Amount must be greater than zero');
    });

    test('rejects more than two decimal places', () {
      expect(
        Validators.amount('10.555'),
        'Amount can have at most 2 decimal places',
      );
    });

    test('accepts valid amounts', () {
      for (final value in ['1', '1500', '0.5', '10.', '25450.75']) {
        expect(Validators.amount(value), isNull, reason: value);
      }
    });
  });

  group('Validators.remarks', () {
    test('is optional but limited to 200 characters', () {
      expect(Validators.remarks(null), isNull);
      expect(Validators.remarks(''), isNull);
      expect(Validators.remarks('a' * 201), isNotNull);
    });
  });
}

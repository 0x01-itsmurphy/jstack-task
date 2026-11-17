abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _mobilePattern = RegExp(r'^[6-9]\d{9}$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? beneficiaryName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Beneficiary name is required';
    if (name.length > 100) return 'Beneficiary name is too long';
    return null;
  }

  static String? mobileNumber(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return 'Mobile number is required';
    if (!_mobilePattern.hasMatch(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? amount(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Amount is required';
    final amount = double.tryParse(input);
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return 'Amount must be greater than zero';
    if (input.contains('.') && input.split('.').last.length > 2) {
      return 'Amount can have at most 2 decimal places';
    }
    return null;
  }

  static String? remarks(String? value) {
    if ((value?.trim().length ?? 0) > 200) {
      return 'Remarks must be 200 characters or fewer';
    }
    return null;
  }
}

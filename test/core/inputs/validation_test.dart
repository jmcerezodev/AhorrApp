import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validation', () {
    test('should return empty error when value is empty', () {
      const email = Email.dirty(value: '');
      expect(email.error, EmailError.empty);
    });

    test('should return format error when email is invalid', () {
      const email = Email.dirty(value: 'invalid-email');
      expect(email.error, EmailError.format);
    });

    test('should be valid when email is correct', () {
      const email = Email.dirty(value: 'test@example.com');
      expect(email.isValid, true);
    });
  });

  group('Password Validation', () {
    test('should return empty error when value is empty', () {
      const password = Password.dirty(value: '');
      expect(password.error, PasswordError.empty);
    });

    test('should return length error when password is too short', () {
      const password = Password.dirty(value: '1234567');
      expect(password.error, PasswordError.length);
    });

    test('should be valid when password is at least 8 characters', () {
      const password = Password.dirty(value: '12345678');
      expect(password.isValid, true);
    });
  });

  group('IncomeMoneyInput Validation', () {
    test('should return empty error when value is empty', () {
      const input = IncomeMoneyInput.dirty(value: '');
      expect(input.error, IncomeMoneyError.empty);
    });

    test('should return format error when value is not a number', () {
      const input = IncomeMoneyInput.dirty(value: 'abc');
      expect(input.error, IncomeMoneyError.format);
    });

    test('should be valid with dots or commas', () {
      expect(const IncomeMoneyInput.dirty(value: '100').isValid, true);
      expect(const IncomeMoneyInput.dirty(value: '100.5').isValid, true);
      expect(const IncomeMoneyInput.dirty(value: '100,5').isValid, true);
    });
    
    test('should be valid with large numbers', () {
      expect(const IncomeMoneyInput.dirty(value: '1200.50').isValid, true);
    });
  });
}

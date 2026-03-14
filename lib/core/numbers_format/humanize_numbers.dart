import 'package:intl/intl.dart';

class HumanizeNumbers {
  String number(double number, {bool isPrivacyModeActive = false}) {
    if (isPrivacyModeActive) {
      return '••••';
    }
    
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(number).trim();
  }
}

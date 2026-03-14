import 'package:intl/intl.dart';

class HumanizeNumbers {
  String number(double number, {bool isPrivacyModeActive = false}) {
    if (isPrivacyModeActive) {
      return '••••';
    }

    final formatter = NumberFormat.decimalPattern('es_ES')
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 2;

    return formatter.format(number).trim();
  }
}



import 'package:intl/intl.dart';

class Date {

  String currentDate(){

    DateTime date = DateTime.now();
    String currentDate = "${date.day}/${date.month}/${date.year}";
    return currentDate;
  }

  String year(){
    DateTime date = DateTime.now();
    int currentYear = date.year;

    return currentYear.toString();
  }

  int monthNumber(){

    DateTime date = DateTime.now();
    int currentMonth = date.month;

    return currentMonth;

  }

  String monthNames(){

    int currentMonth = monthNumber();

    List<String> monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

   String currentMonthName = monthNames[currentMonth - 1]; // Restar 1 porque la lista empieza en 0

    return currentMonthName;

  }
  
  String currentHour(){
    final DateTime date = DateTime.now();
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(date);
  }

  String generateTimestampId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}
}
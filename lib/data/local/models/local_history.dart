import 'package:isar/isar.dart';

part 'local_history.g.dart';

@collection
class LocalHistory {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String appwriteId;

  late String name;
  late double money;
  late bool isIncome;
  late String type; // 'income', 'expense'
  late String currentDate;
  late String currentHour;
  late String month;
  late int year;
  late DateTime createdAt;
  
  late bool isRecurrent; 
  late String category;
  String? ticketId; // ID del ticket asociado para permitir vinculación y reversión
  String? imagePath; // Ruta de la imagen del ticket
  late bool isTransferred; // Indica si viene de un ticket
}

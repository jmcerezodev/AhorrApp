import 'package:isar/isar.dart';

part 'local_ticket_item.g.dart';

@Collection()
class LocalTicketItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String ticketItemId;

  late String userId;
  late String name; // Establecimiento
  late double amount; // Total
  late DateTime date;
  String? imagePath;
  late String category;
  late int position;
}

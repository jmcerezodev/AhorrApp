import 'package:isar/isar.dart';

part 'pending_sync.g.dart';

@collection
class PendingSync {
  Id id = Isar.autoIncrement;

  late String action; // 'create', 'update', 'delete'
  late String collection; // 'history', 'savings'
  
  // Guardamos los datos como un mapa convertido a String (JSON)
  late String dataJson;
  
  // Para actualizaciones y eliminaciones
  String? appwriteId;

  late DateTime createdAt;
}

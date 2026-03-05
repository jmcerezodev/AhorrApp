import 'package:isar/isar.dart';

part 'local_shopping_template.g.dart';

@collection
class LocalShoppingTemplate {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String appwriteId;

  late String userId;
  late String name;
  
  // Guardaremos los items como una lista de JSON strings o usaremos un formato embebido si Isar lo permite
  // En Isar 3.x no hay soporte nativo para listas de objetos complejos sin enlaces, 
  // así que lo guardaremos como un String JSON para simplificar.
  late String itemsJson;

  late DateTime createdAt;
}

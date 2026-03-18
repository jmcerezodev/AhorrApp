import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';
class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client();
    
    if (Env.appwriteEndpoint.isNotEmpty) {
      client
        ..setEndpoint(Env.appwriteEndpoint)
        ..setProject(Env.appwriteProjectId)
        ..setSelfSigned(status: true);
    }

    // Inicializamos los servicios DESPUÉS de configurar el cliente
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}

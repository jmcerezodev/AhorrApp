import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

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
    } else {
      if (kDebugMode) {
        print('⚠️ APPWRITE_ENDPOINT no configurado. Esto es normal en entorno de tests.');
      }
    }

    // Inicializamos los servicios DESPUÉS de configurar el cliente
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}

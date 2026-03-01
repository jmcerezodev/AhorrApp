import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  late Client client;
  late Account account;
  late Databases databases;

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client();
    
    // Solo configuramos si hay datos. Si no los hay, el crash ocurrirá 
    // al intentar una petición, no al inicializar el Cubit.
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

    account = Account(client);
    databases = Databases(client);
  }
}

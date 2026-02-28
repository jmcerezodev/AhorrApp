import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  late Client client;
  late Account account;
  late Databases databases;

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client()
      ..setEndpoint(Env.appwriteEndpoint)
      ..setProject(Env.appwriteProjectId)
      ..setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
  }
}

class Env {
  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: '',
  );

  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '',
  );

  static const String appwriteDatabaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: '',
  );

  static const String appwriteHistoryCollectionId = String.fromEnvironment(
    'APPWRITE_HISTORY_COLLECTION_ID',
    defaultValue: '',
  );

  // NUEVA COLECCIÓN DE AHORROS
  static const String appwriteSavingsCollectionId = String.fromEnvironment(
    'APPWRITE_SAVINGS_COLLECTION_ID',
    defaultValue: '',
  );
}

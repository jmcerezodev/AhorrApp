class Env {
  // Ahora estas constantes leerán los valores inyectados al compilar.
  // Si no se inyectan, estarán vacías, protegiendo tus datos.
  
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
}

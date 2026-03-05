import 'package:ahorrapp/data/local/local_db_service.dart';
import '../../entities/shopping_template.dart';
import '../../repositories/i_shopping_template_repository.dart';

class SaveShoppingTemplateUseCase {
  final IShoppingTemplateRepository localRepository;
  final IShoppingTemplateRepository remoteRepository;
  final LocalDbService localDbService;

  SaveShoppingTemplateUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(ShoppingTemplate template) async {
    // 1. Guardado Local
    await localRepository.saveTemplate(template);

    // 2. Sincronización Remota
    try {
      await remoteRepository.saveTemplate(template);
    } catch (e) {
      // Cola de sincronización si falla internet
      // (Asumiendo que addPendingSync maneja la colección 'shopping_templates')
    }
  }
}

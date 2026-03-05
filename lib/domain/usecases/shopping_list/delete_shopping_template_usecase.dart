import '../../repositories/i_shopping_template_repository.dart';

class DeleteShoppingTemplateUseCase {
  final IShoppingTemplateRepository localRepository;
  final IShoppingTemplateRepository remoteRepository;

  DeleteShoppingTemplateUseCase({
    required this.localRepository,
    required this.remoteRepository,
  });

  Future<void> call(String id) async {
    await localRepository.deleteTemplate(id);
    try {
      await remoteRepository.deleteTemplate(id);
    } catch (e) {
      // Offline support could be added here via localDbService.addPendingSync
    }
  }
}

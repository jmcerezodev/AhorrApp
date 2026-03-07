import 'dart:io';
import '../../entities/ticket_item.dart';
import '../../services/ocr_service.dart';

class ProcessTicketImageUseCase {
  final OCRService ocrService;

  ProcessTicketImageUseCase(this.ocrService);

  Future<List<TicketItem>> call(File imageFile, String userId) async {
    return await ocrService.processTicket(imageFile, userId);
  }
}

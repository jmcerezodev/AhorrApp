import 'package:isar/isar.dart';
import '../../../domain/entities/ticket_item.dart';

part 'local_ticket_item.g.dart';

@Collection()
class LocalTicketItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String ticketItemId;

  late String userId;
  late String name; // Establecimiento
  late double amount; // Total
  late DateTime date;
  String? imagePath;
  String? remoteImageId;
  late String category;
  late int position;
  late bool isTransferred;
  /// Texto OCR crudo. Solo presente cuando ocrStatus == pendingOcr.
  String? rawText;
  @enumerated
  OcrStatus ocrStatus = OcrStatus.completed;
}

import 'dart:io';
import '../entities/ticket_item.dart';

abstract class OCRService {
  Future<List<TicketItem>> processTicket(File imageFile, String userId);
}

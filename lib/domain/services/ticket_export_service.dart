import 'dart:io';

abstract class TicketExportService {
  /// Guarda la imagen en la galería y retorna un mensaje con la ubicación
  Future<String?> saveImageToGallery(File imageFile);

  /// Abre la interfaz de impresión/guardado de PDF del sistema
  Future<void> savePdfWithSystem(File imageFile, String fileName);

  /// Comparte la imagen del ticket
  Future<void> shareTicketImage(File imageFile, String text);
}

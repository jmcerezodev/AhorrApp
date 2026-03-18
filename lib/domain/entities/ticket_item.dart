import 'package:equatable/equatable.dart';

/// Estado de procesamiento OCR/IA del ticket.
/// - [completed]  → nombre y total extraídos correctamente.
/// - [pendingOcr] → imagen guardada, rawText disponible, esperando enviar a la IA.
/// - [error]      → no se pudo extraer texto de la imagen.
enum OcrStatus { completed, pendingOcr, error }

class TicketItem extends Equatable {
  final String id;
  final String userId;
  final String name; // Nombre del establecimiento
  final double amount; // Total del ticket
  final String? imagePath;
  final String? remoteImageId;
  final DateTime date;
  final String category;
  final int position;
  final bool isTransferred;
  /// Texto crudo extraído por ML Kit. Solo se persiste en tickets pendingOcr.
  final String? rawText;
  final OcrStatus ocrStatus;

  const TicketItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    this.imagePath,
    this.remoteImageId,
    this.category = 'general',
    this.position = 0,
    this.isTransferred = false,
    this.rawText,
    this.ocrStatus = OcrStatus.completed,
  });

  TicketItem copyWith({
    String? name,
    double? amount,
    DateTime? date,
    String? imagePath,
    String? remoteImageId,
    String? category,
    int? position,
    bool? isTransferred,
    String? rawText,
    OcrStatus? ocrStatus,
  }) {
    return TicketItem(
      id: id,
      userId: userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      remoteImageId: remoteImageId ?? this.remoteImageId,
      category: category ?? this.category,
      position: position ?? this.position,
      isTransferred: isTransferred ?? this.isTransferred,
      rawText: rawText ?? this.rawText,
      ocrStatus: ocrStatus ?? this.ocrStatus,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, name, amount, date,
        imagePath, remoteImageId, category,
        position, isTransferred, rawText, ocrStatus,
      ];
}

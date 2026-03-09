import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ahorrapp/domain/services/document_scanner_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import '../../../core/shared_preferences/preferences.dart';
import '../../../domain/entities/ticket_item.dart';
import '../../../domain/usecases/tickets/get_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/save_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/delete_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/clear_tickets_usecase.dart';
import '../../../domain/usecases/tickets/reorder_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/process_ticket_image_usecase.dart';

part 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetTicketItemsUseCase getTicketItemsUseCase;
  final SaveTicketItemUseCase saveTicketItemUseCase;
  final DeleteTicketItemUseCase deleteTicketItemUseCase;
  final ClearTicketsUseCase clearTicketsUseCase;
  final ReorderTicketItemsUseCase reorderTicketItemsUseCase;
  final ProcessTicketImageUseCase processTicketImageUseCase;
  final DocumentScannerService documentScannerService;

  TicketsCubit({
    required this.getTicketItemsUseCase,
    required this.saveTicketItemUseCase,
    required this.deleteTicketItemUseCase,
    required this.clearTicketsUseCase,
    required this.reorderTicketItemsUseCase,
    required this.processTicketImageUseCase,
    required this.documentScannerService,
  }) : super(const TicketsState());

  Future<void> loadItems() async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      final items = await getTicketItemsUseCase(Preferences.uId);
      emit(state.copyWith(status: TicketsStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> scanAndProcessTicket() async {
    try {
      final scannedFiles = await documentScannerService.scanDocument();
      if (scannedFiles != null && scannedFiles.isNotEmpty) {
        await processTicketImage(scannedFiles.first);
      }
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: "Error al escanear: $e"));
    }
  }

  Future<void> processTicketImage(File imageFile) async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      // 1. Comprimir imagen en un hilo secundario para no bloquear la UI
      final compressedFile = await _compressImage(imageFile);

      // 2. Guardar la imagen permanentemente en almacenamiento local
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await compressedFile.copy('${appDir.path}/$fileName');

      // 3. Procesar con OCR/AI (Sin esperar a la subida de Appwrite)
      final detectedItems = await processTicketImageUseCase(imageFile, Preferences.uId);
      
      if (detectedItems.isNotEmpty) {
        // El ticket se guarda con la ruta local. La subida a Appwrite se hará en segundo plano (SyncService)
        final ticket = detectedItems.first.copyWith(
          imagePath: savedImage.path,
          remoteImageId: null, // Se asignará durante la sincronización
        );
        await saveTicketItemUseCase(ticket);
      }
      
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: "Error al procesar ticket: $e"));
    }
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    
    // Usamos compute para realizar la decodificación y compresión en un Isolate separado
    final compressedBytes = await compute(_compressImageTask, bytes);
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await tempFile.writeAsBytes(compressedBytes);
  }

  // Función de nivel superior o estática para ser usada con compute
  static Uint8List _compressImageTask(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    img.Image resized = image;
    if (image.width > 1200) {
      resized = img.copyResize(image, width: 1200);
    }

    final compressed = img.encodeJpg(resized, quality: 80);
    return Uint8List.fromList(compressed);
  }

  Future<void> addItem(TicketItem item) async {
    try {
      await saveTicketItemUseCase(item);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateItem(TicketItem item) async {
    try {
      await saveTicketItemUseCase(item);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await deleteTicketItemUseCase(id);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> clearAll() async {
    try {
      await clearTicketsUseCase(Preferences.uId);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    final items = List<TicketItem>.from(state.items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    emit(state.copyWith(items: items));
    
    try {
      await reorderTicketItemsUseCase(items);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }
}

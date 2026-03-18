import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/domain/services/document_scanner_service.dart';
import 'package:ahorrapp/domain/services/ocr_service.dart';
import 'package:ahorrapp/domain/services/ai_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../../core/di/service_locator.dart';
import '../../../core/shared_preferences/preferences.dart';
import '../../../domain/entities/ticket_item.dart';
import '../../../domain/usecases/tickets/get_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/save_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/delete_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/reorder_ticket_items_usecase.dart';

part 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetTicketItemsUseCase getTicketItemsUseCase;
  final SaveTicketItemUseCase saveTicketItemUseCase;
  final DeleteTicketItemUseCase deleteTicketItemUseCase;
  final ReorderTicketItemsUseCase reorderTicketItemsUseCase;
  final OCRService ocrService;
  final AIService aiService;
  final DocumentScannerService documentScannerService;

  TicketsCubit({
    required this.getTicketItemsUseCase,
    required this.saveTicketItemUseCase,
    required this.deleteTicketItemUseCase,
    required this.reorderTicketItemsUseCase,
    required this.ocrService,
    required this.aiService,
    required this.documentScannerService,
  }) : super(const TicketsState());

  Future<void> loadItems() async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      final items = await getTicketItemsUseCase(Preferences.uId);
      emit(state.copyWith(status: TicketsStatus.success, items: items));
      _downloadMissingImagesInBackground();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Actualiza la lista de tickets desde la base de datos local sin emitir estado de carga.
  Future<void> refreshListSilently() async {
    try {
      final items = await getTicketItemsUseCase(Preferences.uId);
      emit(state.copyWith(status: TicketsStatus.success, items: items));
    } catch (_) {}
  }

  void _downloadMissingImagesInBackground() {
    getIt<TicketsRepository>()
        .downloadMissingImages(Preferences.uId)
        .then((_) async {
          final updated = await getTicketItemsUseCase(Preferences.uId);
          if (!isClosed) emit(state.copyWith(items: updated));
        })
        .catchError((_) {});
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> scanAndProcessTicket() async {
    try {
      final scannedFiles = await documentScannerService.scanDocument();
      if (scannedFiles != null && scannedFiles.isNotEmpty) {
        await processTicketImage(scannedFiles.first);
      }
    } catch (e) {
      emit(state.copyWith(
        status: TicketsStatus.failure,
        isProcessingOcr: false,
        errorMessage: 'Error al escanear: $e',
      ));
    }
  }

  Future<void> processTicketImage(File imageFile) async {
    // Iniciamos solo el flag de OCR, sin poner el estado global en loading todavía
    emit(state.copyWith(isProcessingOcr: true));
    
    try {
      // 1. OCR local
      final rawText = await ocrService.extractText(imageFile);

      // Finalizamos flag de OCR antes de seguir con el resto
      emit(state.copyWith(isProcessingOcr: false));

      // 2. Comprimir y guardar imagen de forma permanente
      final compressedFile = await _compressImage(imageFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await compressedFile.copy('${appDir.path}/$fileName');
      if (compressedFile.existsSync()) {
        await compressedFile.delete().catchError((_) => compressedFile);
      }

      // 3. Verificar conectividad antes de enviar a la IA
      bool hasConnection = false;
      try {
        final result = await Connectivity().checkConnectivity();
        hasConnection = result.any((r) => r != ConnectivityResult.none);
      } catch (_) {
        hasConnection = false;
      }

      if (!hasConnection) {
        // Sin red: guardar ticket con ocrStatus: pendingOcr
        await saveTicketItemUseCase(TicketItem(
          id: const Uuid().v4(),
          userId: Preferences.uId,
          name: 'Procesando ticket... ⏳',
          amount: 0.0,
          date: DateTime.now(),
          imagePath: fileName,
          remoteImageId: null,
          rawText: rawText,
          ocrStatus: OcrStatus.pendingOcr,
        ));

        final items = await getTicketItemsUseCase(Preferences.uId);
        emit(state.copyWith(status: TicketsStatus.success, items: items));
        return;
      }

      // 4. Llamada a la IA si hay conexión (aquí sí activamos loading global)
      emit(state.copyWith(status: TicketsStatus.loading));
      final detectedItems = await aiService.processRawText(rawText, Preferences.uId);

      if (detectedItems.isNotEmpty) {
        await saveTicketItemUseCase(detectedItems.first.copyWith(
          imagePath: fileName,
          remoteImageId: null,
          rawText: rawText,
          ocrStatus: OcrStatus.completed,
        ));
      }

      final items = await getTicketItemsUseCase(Preferences.uId);
      emit(state.copyWith(status: TicketsStatus.success, items: items));
      
    } on TimeoutException {
      emit(state.copyWith(
        status: TicketsStatus.failure,
        isProcessingOcr: false,
        errorMessage: 'Conexión lenta o inexistente. Reinténtalo.',
      ));
    } on SocketException {
      emit(state.copyWith(
        status: TicketsStatus.failure,
        isProcessingOcr: false,
        errorMessage: 'Conexión lenta o inexistente. Reinténtalo.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TicketsStatus.failure,
        isProcessingOcr: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    } finally {
      if (state.status == TicketsStatus.loading || state.isProcessingOcr) {
        final items = await getTicketItemsUseCase(Preferences.uId);
        emit(state.copyWith(
          status: TicketsStatus.success, 
          isProcessingOcr: false,
          items: items
        ));
      }
    }
  }

  Future<File> _compressImage(String imagePath) async {
    final compressedBytes = await compute(_compressImageTask, imagePath);
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/save_${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await tempFile.writeAsBytes(compressedBytes);
  }

  static Uint8List _compressImageTask(String path) {
    final bytes = File(path).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    img.Image resized = image;
    if (image.width > 900) {
      resized = img.copyResize(image, width: 900, interpolation: img.Interpolation.linear);
    }

    final compressed = img.encodeJpg(resized, quality: 55);
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

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/domain/services/document_scanner_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../../core/shared_preferences/preferences.dart';
import '../../../domain/entities/ticket_item.dart';
import '../../../domain/usecases/tickets/get_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/save_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/delete_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/reorder_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/process_ticket_image_usecase.dart';

part 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetTicketItemsUseCase getTicketItemsUseCase;
  final SaveTicketItemUseCase saveTicketItemUseCase;
  final DeleteTicketItemUseCase deleteTicketItemUseCase;
  final ReorderTicketItemsUseCase reorderTicketItemsUseCase;
  final ProcessTicketImageUseCase processTicketImageUseCase;
  final DocumentScannerService documentScannerService;
TicketsCubit({
    required this.getTicketItemsUseCase,
    required this.saveTicketItemUseCase,
    required this.deleteTicketItemUseCase,
    required this.reorderTicketItemsUseCase,
    required this.processTicketImageUseCase,
    required this.documentScannerService,
  }) : super(const TicketsState());

  Future<void> loadItems() async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      final items = await getTicketItemsUseCase(Preferences.uId);
      emit(state.copyWith(status: TicketsStatus.success, items: items));
      // Recuperar en background las imágenes que falten (post-reinstalación).
      // No bloquea la UI ni genera un nuevo estado loading.
      _downloadMissingImagesInBackground();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  void _downloadMissingImagesInBackground() {
    getIt<TicketsRepository>()
        .downloadMissingImages(Preferences.uId)
        .then((_) async {
          // Re-carga silenciosa para reflejar las imágenes recién descargadas
          final updated = await getTicketItemsUseCase(Preferences.uId);
          if (!isClosed) emit(state.copyWith(items: updated));
        })
        .catchError((e) {
          debugPrint('[TicketsCubit] Error en descarga de imágenes: $e');
        });
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
      // Si el usuario cancela (null o lista vacía) no hay loading pendiente,
      // el estado queda como estaba (success/initial). No se emite nada.
    } catch (e) {
      // Asegura que si se emitió loading antes del escaneo, queda resuelto.
      emit(state.copyWith(
        status: TicketsStatus.failure,
        errorMessage: 'Error al escanear: $e',
      ));
    }
  }

  Future<void> processTicketImage(File imageFile) async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      // 1. OCR + AI — puede lanzar TimeoutException o Exception de texto vacío
      final detectedItems = await processTicketImageUseCase(imageFile, Preferences.uId);

      // 2. Comprimir para guardar
      final compressedFile = await _compressImage(imageFile.path);

      // 3. Guardar localmente de forma permanente (solo el nombre de archivo,
      //    nunca la ruta absoluta — el UUID del contenedor iOS puede cambiar)
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await compressedFile.copy('${appDir.path}/$fileName');

      if (detectedItems.isNotEmpty) {
        final ticket = detectedItems.first.copyWith(
          imagePath: fileName,
          remoteImageId: null,
        );
        await saveTicketItemUseCase(ticket);
      }

      // Limpieza de temporales de compresión
      if (compressedFile.existsSync()) {
        await compressedFile.delete().catchError((_) => compressedFile);
      }

      // Siempre llega aquí → libera el estado loading con success o failure
      await loadItems();
    } on TimeoutException {
      // El timeout de OpenAI lanzó TimeoutException — libera el loading
      emit(state.copyWith(
        status: TicketsStatus.failure,
        errorMessage: 'La conexión tardó demasiado. Comprueba tu internet e inténtalo de nuevo.',
      ));
    } catch (e) {
      // Cualquier otro error (OCR vacío, JSON malformado, etc.) — libera el loading
      emit(state.copyWith(
        status: TicketsStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
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
    // Optimización fina: 900px de ancho mantiene equilibrio impresión/peso
    if (image.width > 900) {
      resized = img.copyResize(image, width: 900, interpolation: img.Interpolation.linear);
    }

    // Calidad 55% para intentar bajar de los 150KB hacia los 100KB sin ruido excesivo

    // Calidad 55% para intentar bajar de los 150KB hacia los 100KB sin ruido excesivo
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

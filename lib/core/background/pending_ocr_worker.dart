import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/shared_preferences/preferences.dart';
import '../../data/local/local_db_service.dart';
import '../../data/local/models/local_ticket_item.dart';
import '../../data/services/openai_service.dart';
import '../../domain/entities/ticket_item.dart';

/// Identificador único registrado en WorkManager y (en iOS) en Info.plist:
///   <key>BGTaskSchedulerPermittedIdentifiers</key>
///   <array><string>processPendingOcrTicketsV2</string></array>
const String kPendingOcrTaskId = 'processPendingOcrTicketsV2';
const String kPendingOcrTaskName = 'processPendingOcrTicketsV2';

// ---------------------------------------------------------------------------
// Punto de entrada del isolate de background — DEBE ser top-level + @pragma.
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != kPendingOcrTaskName) return true;

    try {
      // Flutter binding requerido por path_provider y shared_preferences
      WidgetsFlutterBinding.ensureInitialized();

      // 1. SharedPreferences — leer userId de forma independiente a la UI
      await Preferences.init();
      final String userId = Preferences.uId;

      if (userId.isEmpty) return true;

      // 2. Isar — apertura totalmente independiente de la UI.
      //    En el isolate del worker, Isar.instanceNames siempre está vacío
      //    (memoria separada), por lo que LocalDbService abre la BD desde cero.
      //    Isar 3.x gestiona el acceso concurrente vía su capa nativa (WAL).
      final dbService = LocalDbService();
      await dbService.init();
      final isar = dbService.isar;

      // 3. Consulta con una sola condición Isar (patrón garantizado en 3.x).
      //    El filtro de userId se aplica en Dart: pendingOcr siempre es un
      //    conjunto pequeño, así que no hay coste de rendimiento.
      final List<LocalTicketItem> allPending = await isar.localTicketItems
          .filter()
          .ocrStatusEqualTo(OcrStatus.pendingOcr)
          .findAll();

      final pendingTickets =
          allPending.where((t) => t.userId == userId).toList();

      if (pendingTickets.isEmpty) return true;

      // 4. Procesar cada ticket con OpenAI
      final aiService = OpenAIService();

      for (final ticket in pendingTickets) {
        final String? rawText = ticket.rawText;

        if (rawText == null || rawText.isEmpty) {
          await isar.writeTxn(() async {
            ticket.ocrStatus = OcrStatus.error;
            ticket.name = 'Sin texto detectado';
            await isar.localTicketItems.put(ticket);
          });
          continue;
        }

        try {
          final results = await aiService.processRawText(rawText, userId);

          if (results.isNotEmpty) {
            final parsed = results.first;

            // 5. Actualizar Isar con los datos reales
            await isar.writeTxn(() async {
              ticket.name = parsed.name;
              ticket.amount = parsed.amount;
              ticket.ocrStatus = OcrStatus.completed;
              await isar.localTicketItems.put(ticket);
            });

            // 6. Encolar sincronización con Appwrite.
            //    SyncService la ejecutará cuando la app esté activa.
            await dbService.addPendingSync(
              'save',
              'tickets',
              {
                'ticketItemId': ticket.ticketItemId,
                'userId': ticket.userId,
                'name': ticket.name,
                'amount': ticket.amount,
                'date': ticket.date.toIso8601String(),
                'category': ticket.category,
                'position': ticket.position,
                'isTransferred': ticket.isTransferred,
                'remoteImageId': ticket.remoteImageId,
                'imagePath': ticket.imagePath,
              },
              appwriteId: ticket.ticketItemId,
            );
          } else {
            await isar.writeTxn(() async {
              ticket.ocrStatus = OcrStatus.error;
              ticket.name = 'No procesado';
              await isar.localTicketItems.put(ticket);
            });
          }
        } on TimeoutException {
          // Mantener pendingOcr para que se reintente en la siguiente ejecución
        } on SocketException {
          // Sin red: se reintentará en la siguiente ejecución
        } catch (_) {
          // Error inesperado: se reintentará
        }
      }

      return true;
    } catch (_) {
      return false; // WorkManager reintentará la tarea
    }
  });
}

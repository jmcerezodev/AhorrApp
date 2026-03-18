import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../core/config/env.dart';
import '../../core/numbers_format/humanize_numbers.dart';
import '../../domain/entities/ticket_item.dart';
import '../../domain/services/ai_service.dart';

class OpenAIService implements AIService {
  static const String _model = 'gpt-4o-mini';
  final http.Client _client;
  final HumanizeNumbers _humanizer = HumanizeNumbers();

  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<TicketItem>> parseTicketText(String rawText, String userId) async {
    if (rawText.isEmpty) return [];

    debugPrint('[OpenAI] Enviando texto (${rawText.length} chars) a la API...');

    try {
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Env.openaiApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''Extrae dos datos de este ticket de compra.

NOMBRE DEL COMERCIO:
- Está casi siempre en las primeras líneas.
- Extrae solo la marca principal. Descarta ciudad, dirección, CIF y sucursal.
- Si no hay nombre claro, devuelve "Desconocido".

TOTAL:
- Busca la línea con "TOTAL", "TOTAL EUR", "A PAGAR", "IMPORTE" o similar.
- Es el número más grande del ticket que NO sea un número de tarjeta (>12 dígitos) ni una fecha.
- Si hay varios totales, usa el mayor.

Responde ÚNICAMENTE con este JSON minificado, sin texto adicional:
{"comercio":"nombre","total":0.00}'''
            },
            {
              'role': 'user',
              'content': rawText
            }
          ],
          'temperature': 0,
          'max_tokens': 80,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          '[OpenAI] La petición superó los 15 segundos sin respuesta.',
        ),
      );

      debugPrint('[OpenAI] Respuesta recibida. HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('usage')) {
          final usage = data['usage'];
          debugPrint('[OpenAI] Tokens usados: ${usage['total_tokens'] ?? 0}');
        }

        final String content = _cleanJsonResponse(data['choices'][0]['message']['content']);
        debugPrint('[OpenAI] JSON recibido: $content');

        final Map<String, dynamic> jsonMap = jsonDecode(content);

        final String name = jsonMap['comercio']?.toString() ?? 'Desconocido';
        final double p = _parseToDouble(jsonMap['total']);

        return [
          TicketItem(
            id: const Uuid().v4(),
            userId: userId,
            name: _capitalize(name),
            amount: p,
            date: DateTime.now(),
            category: 'general',
          )
        ];
      } else {
        debugPrint('Error API OpenAI: ${response.statusCode} - ${response.body}');
        return [];
      }
    } on TimeoutException catch (e) {
      debugPrint('[OpenAI] Timeout: $e');
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[OpenAI] Sin conexión de red: $e');
      rethrow;
    } catch (e) {
      debugPrint('[OpenAI] Error: $e');
      return [];
    }
  }

  @override
  Future<List<TicketItem>> processRawText(String rawText, String userId) =>
      parseTicketText(rawText, userId);

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    
    // Lógica robusta: limpieza y conversión de coma a punto
    final String rawPrice = value.toString().replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(rawPrice) ?? 0.0;
  }

  String _cleanJsonResponse(String content) => content.replaceAll('```json', '').replaceAll('```', '').trim();

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final String clean = text.trim();
    if (clean.toLowerCase() == 'desconocido') return 'Desconocido';
    
    return clean.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../core/config/env.dart';
import '../../domain/entities/ticket_item.dart';
import '../../domain/services/ai_service.dart';

class OpenAIService implements AIService {
  static const String _model = 'gpt-4o-mini';
  final http.Client _client;

  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<TicketItem>> parseTicketText(String rawText, String userId) async {
    if (rawText.isEmpty) return [];

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
              'content': '''Eres un extractor experto de tickets de compra.
Tu objetivo es identificar el NOMBRE DEL ESTABLECIMIENTO y el IMPORTE TOTAL.

INSTRUCCIONES CRÍTICAS:
1. El NOMBRE DEL ESTABLECIMIENTO suele estar al principio. Puede ocupar una o VARIAS LÍNEAS consecutivas. Debes CONCATENARLAS en una sola frase coherente.
2. EXTRAE ÚNICAMENTE LA MARCA COMERCIAL PRINCIPAL. Elimina ciudades, barrios, centros comerciales, sucursales o direcciones.
3. El IMPORTE TOTAL es el valor final asociado a "TOTAL", "TOTAL EUR", "A PAGAR" o similar.
4. Formato de salida: SOLO un JSON minificado {"n":"nombre_comercio_completo","p":importe_total}.
5. Si no hay un nombre claro al inicio, usa "Ticket".'''
            },
            {
              'role': 'user',
              'content': rawText
            }
          ],
          'temperature': 0,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- REGISTRO DE TOKENS REALES ---
        if (data.containsKey('usage')) {
          final usage = data['usage'];
          final int promptTokens = usage['prompt_tokens'] ?? 0;
          final int completionTokens = usage['completion_tokens'] ?? 0;
          final int totalTokens = usage['total_tokens'] ?? 0;

          debugPrint('📊 [OpenAI Usage] Model: $_model');
          debugPrint('   🔹 Prompt Tokens: $promptTokens');
          debugPrint('   🔹 Completion Tokens: $completionTokens');
          debugPrint('   🔹 Total Tokens: $totalTokens');
        }

        final String content = _cleanJsonResponse(data['choices'][0]['message']['content']);
        final Map<String, dynamic> jsonMap = jsonDecode(content);

        final String name = jsonMap['n']?.toString() ?? 'Ticket';
        final double p = _parseToDouble(jsonMap['p']);

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
    } catch (e) {
      debugPrint('Error parseando IA: $e');
      return [];
    }
  }

  double _parseToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      String clean = value.replaceAll(RegExp(r'[^0-9\.\,]'), '').replaceAll(',', '.');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  String _cleanJsonResponse(String content) => content.replaceAll('```json', '').replaceAll('```', '').trim();

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final String clean = text.trim();
    if (clean.toLowerCase() == 'ticket') return 'Ticket';
    
    return clean.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

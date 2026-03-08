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

  // Contadores persistentes durante la sesión (se resetean con Hot Restart)
  static int _sessionPromptTokens = 0;
  static int _sessionCompletionTokens = 0;

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
INSTRUCCIONES:
1. Extrae cada producto individual del ticket.
2. Si el precio está en una línea diferente al nombre, asócialos inteligentemente.
3. Formato: SOLO un JSON minificado [{"n":"nombre","q":cantidad,"p":precio_unitario}].
4. REGLA ORO: Agrupa mismo nombre Y mismo precio (suma q). Si el precio es distinto, mantenlos como items SEPARADOS.
5. NO incluyas subtotales, IVAs ni Totales.'''
            },
            {
              'role': 'user',
              'content': rawText
            }
          ],
          'temperature': 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usage = data['usage'];
        
        if (usage != null) {
          final int pTokens = (usage['prompt_tokens'] ?? 0) as int;
          final int cTokens = (usage['completion_tokens'] ?? 0) as int;
          
          _sessionPromptTokens += pTokens;
          _sessionCompletionTokens += cTokens;
          
          debugPrint('--- [OPENAI TOKEN REPORT] ---');
          debugPrint('LLAMADA ACTUAL:');
          debugPrint('  -> Prompt (Entrada): $pTokens');
          debugPrint('  -> Completion (Salida): $cTokens');
          debugPrint('  -> TOTAL LLAMADA: ${pTokens + cTokens}');
          debugPrint('ACUMULADO SESIÓN:');
          debugPrint('  -> Total Prompt: $_sessionPromptTokens');
          debugPrint('  -> Total Completion: $_sessionCompletionTokens');
          debugPrint('  -> GLOBAL TOTAL: ${_sessionPromptTokens + _sessionCompletionTokens}');
          debugPrint('------------------------------');
        }

        final String content = _cleanJsonResponse(data['choices'][0]['message']['content']);
        final List<dynamic> jsonList = jsonDecode(content);

        return jsonList.map((item) {
          if (item is! Map) return null;

          final String name = item['n']?.toString() ?? 'Producto';
          final int q = _parseToInt(item['q']);
          final double p = _parseToDouble(item['p']);

          return TicketItem(
            id: const Uuid().v4(),
            userId: userId,
            name: _capitalize(name),
            amount: p,
            quantity: q,
            category: 'general',
          );
        }).whereType<TicketItem>().toList();
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
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9\.\,]'), '').replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  int _parseToInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    }
    return 1;
  }

  String _cleanJsonResponse(String content) => content.replaceAll('```json', '').replaceAll('```', '').trim();

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final String clean = text.trim();
    return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
  }
}

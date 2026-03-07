import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../core/config/env.dart';
import '../../domain/entities/ticket_item.dart';
import '../../domain/services/ai_service.dart';

class OpenAIService implements AIService {
  // Cambiamos a gpt-4o-mini: más inteligente, rápido y barato.
  static const String _model = 'gpt-4o-mini';

  final http.Client _client;

  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  // Contadores globales de tokens
  static int _totalPromptTokens = 0;
  static int _totalCompletionTokens = 0;

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
              'content': '''Eres un extractor de datos de tickets ultra preciso. 
Input: líneas de texto separadas por "|". 
Reglas:
1. Extrae cada producto como un objeto JSON.
2. AGRUPA productos con el MISMO NOMBRE y MISMO PRECIO incrementando la cantidad "q".
3. NO agrupes productos con mismo nombre si tienen DISTINTO precio.
4. "p" debe ser SIEMPRE el PRECIO UNITARIO del producto, nunca el total de la línea.
5. NO inventes datos. q=1 por defecto si no se detecta.
6. Output: SOLO un array JSON minificado. Llaves: "n","q","p".
7. NO incluyas IVAs, Subtotales o Totales.

Ejemplo:
Input:
LECHE | 1.50
PAN | 0.50
PAN | 0.50
PAN | 0.45
Output:
[{"n":"LECHE","q":1,"p":1.5},{"n":"PAN","q":2,"p":0.5},{"n":"PAN","q":1,"p":0.45}]'''
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
          final int promptTokens = usage['prompt_tokens'] ?? 0;
          final int completionTokens = usage['completion_tokens'] ?? 0;
          
          _totalPromptTokens += promptTokens;
          _totalCompletionTokens += completionTokens;

          debugPrint('--- OPENAI TOKEN USAGE (gpt-4o-mini) ---');
          debugPrint('Llamada actual -> Prompt: $promptTokens | Completion: $completionTokens | Total: ${promptTokens + completionTokens}');
          debugPrint('Acumulado total -> Prompt: $_totalPromptTokens | Completion: $_totalCompletionTokens | Global: ${_totalPromptTokens + _totalCompletionTokens}');
          debugPrint('----------------------------------------');
        }

        final String content = data['choices'][0]['message']['content'];
        final List<dynamic> jsonList = jsonDecode(_cleanJsonResponse(content));

        return jsonList.map((item) {
          final String name = item['n'] ?? 'Producto';
          return TicketItem(
            id: const Uuid().v4(),
            userId: userId,
            name: _capitalize(name),
            amount: (item['p'] ?? 0.0).toDouble(),
            quantity: (item['q'] ?? 1).toInt(),
            category: 'general',
          );
        }).toList();
      } else {
        throw Exception('Error OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en AIService: $e');
      return [];
    }
  }

  String _cleanJsonResponse(String content) {
    return content.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final String clean = text.toLowerCase();
    return clean[0].toUpperCase() + clean.substring(1);
  }
}

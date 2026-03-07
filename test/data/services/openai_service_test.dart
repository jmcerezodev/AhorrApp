import 'dart:convert';
import 'package:ahorrapp/data/services/openai_service.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late OpenAIService openAiService;
  late MockClient mockClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockClient();
    openAiService = OpenAIService(client: mockClient);
  });

  group('OpenAIService Tests', () {
    const userId = 'user123';
    const rawText = 'LECHE | 1.50\nPAN | 0.50\nPAN | 0.50';
    
    final mockResponse = {
      'choices': [
        {
          'message': {
            'content': '[{"n":"LECHE","q":1,"p":1.5},{"n":"PAN","q":2,"p":0.5}]'
          }
        }
      ],
      'usage': {
        'prompt_tokens': 100,
        'completion_tokens': 50
      }
    };

    test('parseTicketText retorna lista de TicketItem correctamente agrupados', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await openAiService.parseTicketText(rawText, userId);

      expect(result.length, 2);
      expect(result[0].name, 'Leche');
      expect(result[0].amount, 1.5);
      expect(result[0].quantity, 1);
      
      expect(result[1].name, 'Pan');
      expect(result[1].amount, 0.5);
      expect(result[1].quantity, 2);
    });

    test('parseTicketText retorna lista vacía si rawText está vacío', () async {
      final result = await openAiService.parseTicketText('', userId);
      expect(result, isEmpty);
      verifyNever(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')));
    });

    test('parseTicketText maneja errores de la API retornando lista vacía', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Error', 500));

      final result = await openAiService.parseTicketText(rawText, userId);
      expect(result, isEmpty);
    });
  });
}

import 'dart:convert';
import 'package:ahorrapp/data/services/openai_service.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late OpenAIService openAIService;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    openAIService = OpenAIService(client: mockHttpClient);
  });

  group('OpenAIService - parseTicketText', () {
    const String userId = 'user-123';
    const String rawText = 'MERCADONA S.A.\nCALLE FALSA 123\nTOTAL 45,67€';

    test('should return a valid TicketItem on success', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': '{"n":"MERCADONA","p":45.67}'
            }
          }
        ],
        'usage': {'total_tokens': 120}
      };

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await openAIService.parseTicketText(rawText, userId);

      expect(results, isNotEmpty);
      expect(results.first.name, 'Mercadona');
      expect(results.first.amount, 45.67);
    });

    test('should handle malformed JSON from OpenAI gracefully', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': 'Error: No he podido leer el ticket'
            }
          }
        ]
      };

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await openAIService.parseTicketText(rawText, userId);

      expect(results, isEmpty);
    });

    test('should return default "Ticket" if name is missing in JSON', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': '{"p":10.50}'
            }
          }
        ]
      };

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await openAIService.parseTicketText(rawText, userId);

      expect(results, isNotEmpty);
      expect(results.first.name, 'Ticket');
      expect(results.first.amount, 10.50);
    });

    test('should handle HTTP errors from OpenAI API', () async {
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      final results = await openAIService.parseTicketText(rawText, userId);

      expect(results, isEmpty);
    });

    test('should parse amounts correctly even if they come as strings with symbols', () async {
      // Contenido interno limpio
      const String aiContent = '{"n": "Lidl", "p": "12,99"}'; 

      final mockResponseBody = jsonEncode({
        "choices": [
          {
            "message": {"content": aiContent}
          }
        ],
        "usage": {"total_tokens": 100}
      });

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      final results = await openAIService.parseTicketText(rawText, userId);

      expect(results, isNotEmpty);
      expect(results.first.amount, 12.99);
      expect(results.first.name, 'Lidl');
    });
  });
}

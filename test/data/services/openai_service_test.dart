import 'dart:convert';
import 'package:ahorrapp/data/services/openai_service.dart';
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

  group('OpenAIService - Robust Parsing & Token Tracking', () {
    const userId = 'user123';
    const rawText = 'MERCADONA | 15.50';

    test('debe extraer establecimiento y total correctamente', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': '{"n":"Mercadona","p":"15,50"}'
            }
          }
        ]
      };

      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await openAiService.parseTicketText(rawText, userId);

      expect(result.length, 1);
      expect(result[0].name, 'Mercadona');
      expect(result[0].amount, 15.50);
    });

    test('debe concatenar nombres de establecimiento en varias líneas correctamente', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': '{"n":"Bar El Rincon De Morales","p":12.50}'
            }
          }
        ]
      };

      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await openAiService.parseTicketText('BAR EL RINCON\nDE MORALES\nTOTAL 12.50', userId);

      expect(result[0].name, 'Bar El Rincon De Morales');
      expect(result[0].amount, 12.50);
    });

    test('debe ser resiliente a JSON malformados', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {
              'content': 'esto no es json'
            }
          }
        ]
      };

      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Silenciamos el log de error esperado durante el test
      final result = await openAiService.parseTicketText(rawText, userId);
      expect(result, isEmpty);
    });
  });
}

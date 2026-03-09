import 'dart:ui';
import 'package:ahorrapp/data/services/google_mlkit_ocr_service.dart';
import 'package:ahorrapp/domain/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';

class MockAIService extends Mock implements AIService {}
class MockRecognizedText extends Mock implements RecognizedText {}
class MockTextBlock extends Mock implements TextBlock {}
class MockTextLine extends Mock implements TextLine {}

void main() {
  late GoogleMlKitOCRService ocrService;
  late MockAIService mockAiService;

  setUp(() {
    mockAiService = MockAIService();
    ocrService = GoogleMlKitOCRService(mockAiService);
  });

  group('GoogleMlKitOCRService - Text Optimization', () {
    test('extractOptimizedText debe colapsar espacios y filtrar ruido', () {
      final mockText = MockRecognizedText();
      final mockBlock = MockTextBlock();
      final mockLine1 = MockTextLine();
      final mockLine2 = MockTextLine();

      when(() => mockLine1.text).thenReturn('PRODUCTO    EXTRA 1.50');
      when(() => mockLine1.boundingBox).thenReturn(const Rect.fromLTWH(0, 100, 100, 20));

      // 'mesa' es una noiseKeyword en la regex, debe filtrarse
      when(() => mockLine2.text).thenReturn('Mesa: 5');
      when(() => mockLine2.boundingBox).thenReturn(const Rect.fromLTWH(0, 200, 100, 20));

      when(() => mockBlock.lines).thenReturn([mockLine1, mockLine2]);
      when(() => mockText.blocks).thenReturn([mockBlock]);

      final result = ocrService.extractOptimizedText(mockText);

      expect(result, contains('PRODUCTO EXTRA 1.50'));
      expect(result, isNot(contains('Mesa')));
    });

    test('extractOptimizedText debe unir líneas en la misma fila (umbral 25px)', () {
      final mockText = MockRecognizedText();
      final mockBlock = MockTextBlock();
      final mockLine1 = MockTextLine();
      final mockLine2 = MockTextLine();

      when(() => mockLine1.text).thenReturn('PAN');
      when(() => mockLine1.boundingBox).thenReturn(const Rect.fromLTWH(0, 100, 50, 20));
      
      when(() => mockLine2.text).thenReturn('0.50');
      when(() => mockLine2.boundingBox).thenReturn(const Rect.fromLTWH(100, 110, 50, 20));

      when(() => mockBlock.lines).thenReturn([mockLine1, mockLine2]);
      when(() => mockText.blocks).thenReturn([mockBlock]);

      final result = ocrService.extractOptimizedText(mockText);

      expect(result, contains('PAN | 0.50'));
    });

    test('extractOptimizedText debe PERMITIR líneas sin números para capturar el nombre del comercio', () {
      final mockText = MockRecognizedText();
      final mockBlock = MockTextBlock();
      final mockLine = MockTextLine();

      when(() => mockLine.text).thenReturn('BAR EL RINCON DE MORALES');
      when(() => mockLine.boundingBox).thenReturn(const Rect.fromLTWH(0, 100, 100, 20));

      when(() => mockBlock.lines).thenReturn([mockLine]);
      when(() => mockText.blocks).thenReturn([mockBlock]);

      final result = ocrService.extractOptimizedText(mockText);

      expect(result, equals('BAR EL RINCON DE MORALES'));
    });
  });
}

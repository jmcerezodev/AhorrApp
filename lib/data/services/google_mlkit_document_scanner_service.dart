import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/document_scanner_service.dart';
// Canales nativos activos (sin conflicto entre ellos):
//   dev.jmcerezo.ahorrapp/document_scanner → VisionKit nativo (AppDelegate.swift)
//   google_mlkit_document_scanner → canal de ML Kit (Android only)
//   dev.jmcerezo.ahorrapp/security → canal custom de seguridad

/// Canal que apunta a la implementación VisionKit en AppDelegate.swift.
/// No se usa cunning_document_scanner porque ese plugin llama a result()
/// antes de dismiss() en iOS 15, dejando el Future de Dart colgado.
const _visionKitChannel = MethodChannel('dev.jmcerezo.ahorrapp/document_scanner');

/// En Android usa el escáner nativo de Google ML Kit (con recorte automático,
/// corrección de perspectiva, etc.). En iOS usa CunningDocumentScanner, que
/// invoca VNDocumentCameraViewController de VisionKit (la misma interfaz que
/// la app Notas de Apple, con detección automática de bordes del ticket).
class GoogleMlKitDocumentScannerService implements DocumentScannerService {
  DocumentScanner? _androidScanner;

  DocumentScanner get _scanner {
    _androidScanner ??= DocumentScanner(
      options: DocumentScannerOptions(
        mode: ScannerMode.base,
        pageLimit: 1,
      ),
    );
    return _androidScanner!;
  }

  @override
  Future<List<File>?> scanDocument() async {
    if (Platform.isIOS) {
      return _scanWithVisionKitIOS();
    }
    return _scanWithMlKitAndroid();
  }

  Future<List<File>?> _scanWithMlKitAndroid() async {
    try {
      final result = await _scanner.scanDocument();
      return result.images?.map((path) => File(path)).toList();
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Abre la interfaz nativa de Apple (VisionKit) para escanear documentos.
  /// Detecta automáticamente los bordes del ticket igual que la app Notas.
  /// Devuelve null si el usuario cancela deslizando hacia abajo.
  Future<List<File>?> _scanWithVisionKitIOS() async {
    try {
      final List<dynamic>? paths =
          await _visionKitChannel.invokeMethod<List<dynamic>>('scanDocument');
      // Lista vacía = usuario canceló
      if (paths == null || paths.isEmpty) return null;
      return paths.cast<String>().map((path) => File(path)).toList();
    } on PlatformException {
      return _scanWithImagePickerFallback();
    } catch (_) {
      return _scanWithImagePickerFallback();
    }
  }

  /// Cámara estándar como fallback si VisionKit falla (p.ej. MissingPluginException).
  Future<List<File>?> _scanWithImagePickerFallback() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) return null;
      return [File(picked.path)];
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _androidScanner?.close();
    _androidScanner = null;
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/document_scanner_service.dart';

/// En Android usa el escáner nativo de Google ML Kit (con recorte automático,
/// corrección de perspectiva, etc.). En iOS, Google no ofrece esa API, así que
/// se usa image_picker con la cámara, que es la única alternativa disponible.
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
      return _scanWithImagePickerIOS();
    }
    return _scanWithMlKitAndroid();
  }

  Future<List<File>?> _scanWithMlKitAndroid() async {
    try {
      final result = await _scanner.scanDocument();
      return result.images?.map((path) => File(path)).toList();
    } on PlatformException catch (e) {
      debugPrint('DEBUG_ANDROID_SCANNER: ${e.message} | code: ${e.code}');
      return null;
    } catch (e) {
      debugPrint('DEBUG_ANDROID_SCANNER: $e');
      return null;
    }
  }

  Future<List<File>?> _scanWithImagePickerIOS() async {
    try {
      final picker = ImagePicker();
      // Ofrece cámara directamente (equivalente al escáner en Android).
      // imageQuality=95 para dar al OCR la mejor calidad posible.
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) return null;
      return [File(picked.path)];
    } on PlatformException catch (e) {
      debugPrint('DEBUG_IOS_SCANNER: ${e.message} | code: ${e.code}');
      return null;
    } catch (e) {
      debugPrint('DEBUG_IOS_SCANNER: $e');
      return null;
    }
  }

  void dispose() {
    _androidScanner?.close();
    _androidScanner = null;
  }
}

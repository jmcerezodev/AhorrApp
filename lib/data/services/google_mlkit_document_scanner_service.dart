import 'dart:io';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../domain/services/document_scanner_service.dart';

class GoogleMlKitDocumentScannerService implements DocumentScannerService {
  final _documentScanner = DocumentScanner(
    options: DocumentScannerOptions(
      mode: ScannerMode.base,
      pageLimit: 1,
    ),
  );

  @override
  Future<List<File>?> scanDocument() async {
    try {
      final result = await _documentScanner.scanDocument();
      return result.images?.map((path) => File(path)).toList();
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _documentScanner.close();
  }
}

import 'dart:io';

abstract class DocumentScannerService {
  Future<List<File>?> scanDocument();
}

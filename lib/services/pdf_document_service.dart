import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

class PdfProcessResult {
  PdfProcessResult({
    required this.documentCode,
    required this.documentText,
    required this.localPath,
    required this.fileName,
    required this.codeFound,
    required this.textFound,
    required this.textTruncated,
  });

  final String documentCode;
  final String documentText;
  final String localPath;
  final String fileName;
  final bool codeFound;
  final bool textFound;
  final bool textTruncated;
}

class PdfDocumentService {
  static const int _maxTextLength = 12000;

  Future<PdfProcessResult?> pickAndProcessPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final path = file.path;
    if (path == null) {
      throw Exception('Arquivo invalido.');
    }

    final bytes = await File(path).readAsBytes();
    final qrCode = await _extractQrCode(bytes);
    final normalizedCode = qrCode?.trim();
    final codeFound = normalizedCode != null && normalizedCode.isNotEmpty;
    final documentCode = codeFound ? normalizedCode : _generateCode();

    final text = _extractText(bytes).trim();
    final textFound = text.isNotEmpty;
    var normalizedText = text;
    var textTruncated = false;

    if (normalizedText.length > _maxTextLength) {
      normalizedText = normalizedText.substring(0, _maxTextLength);
      textTruncated = true;
    }

    final localPath = await _saveLocalCopy(path, documentCode);

    return PdfProcessResult(
      documentCode: documentCode,
      documentText: normalizedText,
      localPath: localPath,
      fileName: file.name,
      codeFound: codeFound,
      textFound: textFound,
      textTruncated: textTruncated,
    );
  }

  Future<String?> _extractQrCode(Uint8List bytes) async {
    pdfx.PdfDocument? document;
    pdfx.PdfPage? page;
    BarcodeScanner? scanner;

    try {
      document = await pdfx.PdfDocument.openData(bytes);
      page = await document.getPage(1);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.png,
      );

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/qr_scan_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (pageImage == null) return null;
      await tempFile.writeAsBytes(pageImage.bytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);
      scanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
      final codes = await scanner.processImage(inputImage);
      for (final code in codes) {
        final value = code.rawValue;
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return null;
    } finally {
      await scanner?.close();
      if (page != null) {
        await page.close();
      }
      await document?.close();
    }
  }

  String _extractText(Uint8List bytes) {
    final document = sfpdf.PdfDocument(inputBytes: bytes);
    final extractor = sfpdf.PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();
    return text;
  }

  Future<String> _saveLocalCopy(String sourcePath, String documentCode) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${directory.path}/documentos');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final safeCode = documentCode
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .toUpperCase();
    final fileName =
        '${safeCode}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final targetPath = '${targetDir.path}/$fileName';

    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  String _generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'DOC-$timestamp';
  }
}

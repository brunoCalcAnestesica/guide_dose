import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Serviço para gerar PDFs a partir de conversas do chat.
/// 
/// Funcionalidades:
/// - Geração de PDF com formatação profissional
/// - Suporte a Markdown (títulos, listas, etc.)
/// - Inclusão de logo e dados do paciente
/// - Compartilhamento do PDF gerado
class ChatPdfService {
  // IMPORTANTE: Ajuste o caminho do logo para o seu app
  static const String _logoAssetPath = 'assets/imagen/logo_g_bg_1024.png';
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF1E223C);

  Uint8List? _logoBytes;

  Future<void> _loadLogo() async {
    if (_logoBytes != null) return;
    try {
      final data = await rootBundle.load(_logoAssetPath);
      _logoBytes = data.buffer.asUint8List();
    } catch (_) {
      _logoBytes = null;
    }
  }

  /// Gera um PDF a partir do conteúdo do chat.
  Future<String> generatePdf({
    required String title,
    required String content,
    String? patientContext,
  }) async {
    await _loadLogo();

    final pdf = pw.Document();
    final now = DateTime.now();

    pw.MemoryImage? logoImage;
    if (_logoBytes != null) {
      logoImage = pw.MemoryImage(_logoBytes!);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(logoImage, now),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildTitle(title),
          if (patientContext != null && patientContext.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _buildPatientContext(patientContext),
          ],
          pw.SizedBox(height: 20),
          _buildContent(content),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    // IMPORTANTE: Ajuste o nome da pasta para o seu app
    final exportsDir = Directory('${directory.path}/medical_ai/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final safeTitle = title
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final fileName = 'medical_ai_${safeTitle}_${now.millisecondsSinceEpoch}.pdf';
    final filePath = '${exportsDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  /// Compartilha o PDF gerado.
  Future<void> sharePdf(String filePath) async {
    final file = XFile(filePath);
    // IMPORTANTE: Ajuste a mensagem para o seu app
    await Share.shareXFiles([file], text: 'Documento gerado pela IA Médica');
  }

  pw.Widget _buildHeader(pw.MemoryImage? logoImage, DateTime now) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoImage != null)
            pw.Container(
              width: 40,
              height: 40,
              child: pw.Image(logoImage),
            ),
          if (logoImage != null) pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  // IMPORTANTE: Ajuste o nome do seu app
                  'IA Médica',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.Text(
                  'Assistente Medico Inteligente',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                _formatDate(now),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                _formatTime(now),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            // IMPORTANTE: Ajuste o texto do rodapé
            'IA Médica - Documento gerado por IA',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.Text(
            'Pagina ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F5F5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: _primaryColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPatientContext(String context) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Dados do Paciente',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            context,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildContent(String content) {
    final paragraphs = _parseContent(content);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: paragraphs.map((p) => _buildParagraph(p)).toList(),
    );
  }

  List<_ContentParagraph> _parseContent(String content) {
    final lines = content.split('\n');
    final paragraphs = <_ContentParagraph>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        paragraphs.add(_ContentParagraph(text: '', type: _ParagraphType.space));
        continue;
      }

      if (trimmed.startsWith('### ')) {
        paragraphs.add(_ContentParagraph(
          text: trimmed.substring(4),
          type: _ParagraphType.heading3,
        ));
      } else if (trimmed.startsWith('## ')) {
        paragraphs.add(_ContentParagraph(
          text: trimmed.substring(3),
          type: _ParagraphType.heading2,
        ));
      } else if (trimmed.startsWith('# ')) {
        paragraphs.add(_ContentParagraph(
          text: trimmed.substring(2),
          type: _ParagraphType.heading1,
        ));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        paragraphs.add(_ContentParagraph(
          text: trimmed.substring(2),
          type: _ParagraphType.bullet,
        ));
      } else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        final match = RegExp(r'^\d+\.\s(.*)').firstMatch(trimmed);
        paragraphs.add(_ContentParagraph(
          text: match?.group(1) ?? trimmed,
          type: _ParagraphType.numbered,
          number: paragraphs.where((p) => p.type == _ParagraphType.numbered).length + 1,
        ));
      } else if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
        paragraphs.add(_ContentParagraph(
          text: trimmed.substring(2, trimmed.length - 2),
          type: _ParagraphType.bold,
        ));
      } else {
        paragraphs.add(_ContentParagraph(
          text: _cleanMarkdown(trimmed),
          type: _ParagraphType.normal,
        ));
      }
    }

    return paragraphs;
  }

  String _cleanMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'\1')
        .replaceAll(RegExp(r'`(.+?)`'), r'\1');
  }

  pw.Widget _buildParagraph(_ContentParagraph paragraph) {
    switch (paragraph.type) {
      case _ParagraphType.space:
        return pw.SizedBox(height: 8);

      case _ParagraphType.heading1:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
          child: pw.Text(
            paragraph.text,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        );

      case _ParagraphType.heading2:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
          child: pw.Text(
            paragraph.text,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        );

      case _ParagraphType.heading3:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
          child: pw.Text(
            paragraph.text,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        );

      case _ParagraphType.bullet:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 16,
                child: pw.Text(
                  '•',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  paragraph.text,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );

      case _ParagraphType.numbered:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 20,
                child: pw.Text(
                  '${paragraph.number}.',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  paragraph.text,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );

      case _ParagraphType.bold:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            paragraph.text,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );

      case _ParagraphType.normal:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            paragraph.text,
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.justify,
          ),
        );
    }
  }

  String _formatDate(DateTime date) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }
}

enum _ParagraphType {
  space,
  heading1,
  heading2,
  heading3,
  bullet,
  numbered,
  bold,
  normal,
}

class _ContentParagraph {
  _ContentParagraph({
    required this.text,
    required this.type,
    this.number,
  });

  final String text;
  final _ParagraphType type;
  final int? number;
}

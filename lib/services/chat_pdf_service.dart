import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ChatPdfService {
  static const String _logoAssetPath = 'assets/imagen/logo_g_bg_1024.png';
  static const PdfColor _primary = PdfColor.fromInt(0xFF1A2848);
  static const double _bodyFontSize = 10.5;
  static const double _h1Size = 15.0;
  static const double _h2Size = 13.0;
  static const double _h3Size = 11.5;

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

  Future<String> generatePdf({
    required String title,
    required String content,
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        header: (context) => _buildHeader(logoImage, now),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 10),
          _buildTitle(title),
          pw.SizedBox(height: 8),
          _buildContent(content),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/guide_dose/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final safeTitle = title
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final fileName =
        'guidedose_${safeTitle}_${now.millisecondsSinceEpoch}.pdf';
    final filePath = '${exportsDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  Future<void> sharePdf(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], text: 'Documento gerado pelo Guide Dose');
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  pw.Widget _buildHeader(pw.MemoryImage? logoImage, DateTime now) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _primary, width: 1.5),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoImage != null)
            pw.Container(
              width: 36,
              height: 36,
              child: pw.Image(logoImage),
            ),
          if (logoImage != null) pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Guide Dose',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _primary,
                  ),
                ),
                pw.Text(
                  'Assistente Medico Inteligente',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          pw.Text(
            '${_fmt2(now.day)}/${_fmt2(now.month)}/${now.year}  ${_fmt2(now.hour)}:${_fmt2(now.minute)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Guide Dose',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Pagina ${context.pageNumber} de ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Este documento foi gerado por inteligencia artificial e deve ser validado por profissional de saude.',
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey400,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Title
  // ---------------------------------------------------------------------------

  pw.Widget _buildTitle(String title) {
    return pw.Column(
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
            letterSpacing: 0.8,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: PdfColors.grey400, thickness: 0.5),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------

  pw.Widget _buildContent(String content) {
    final paragraphs = _parseContent(content);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: paragraphs.map((p) => _buildParagraph(p)).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Markdown parser
  // ---------------------------------------------------------------------------

  static final _backslashSeq = RegExp(r'\\(\d)');
  static final _hrRule = RegExp(r'^-{3,}$|^\*{3,}$|^_{3,}$');
  static final _h3 = RegExp(r'^###\s+(.+)');
  static final _h2 = RegExp(r'^##\s+(.+)');
  static final _h1 = RegExp(r'^#\s+(.+)');
  static final _bullet = RegExp(r'^[-*]\s+(.+)');
  static final _subBullet = RegExp(r'^\s{2,}[-*]\s+(.+)');
  static final _ordered = RegExp(r'^(\d+)\.\s+(.+)');
  static final _boldLine = RegExp(r'^\*\*(.+)\*\*$');

  static final _unicodeJunk = RegExp(
    r'[\u2610\u2611\u2612\u2713\u2714\u2715\u2716\u2717\u2718\u25A0\u25A1\u25AA\u25AB\u25CF\u25CB\u25E6\u2022\u2023\u2043\u00B7]',
  );

  List<_ContentParagraph> _parseContent(String raw) {
    final cleaned = raw
        .replaceAll(_backslashSeq, '')
        .replaceAll(_unicodeJunk, '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final lines = cleaned.split('\n');
    final out = <_ContentParagraph>[];
    int numberedCounter = 0;

    for (final line in lines) {
      final trimmed = line.trimRight();
      final stripped = trimmed.trimLeft();

      if (stripped.isEmpty) {
        numberedCounter = 0;
        out.add(_ContentParagraph(text: '', type: _PType.space));
        continue;
      }

      if (_hrRule.hasMatch(stripped)) {
        out.add(_ContentParagraph(text: '', type: _PType.separator));
        continue;
      }

      RegExpMatch? m;

      if ((m = _h3.firstMatch(stripped)) != null) {
        numberedCounter = 0;
        out.add(_ContentParagraph(text: m!.group(1)!, type: _PType.h3));
      } else if ((m = _h2.firstMatch(stripped)) != null) {
        numberedCounter = 0;
        out.add(_ContentParagraph(text: m!.group(1)!, type: _PType.h2));
      } else if ((m = _h1.firstMatch(stripped)) != null) {
        numberedCounter = 0;
        out.add(_ContentParagraph(text: m!.group(1)!, type: _PType.h1));
      } else if ((m = _subBullet.firstMatch(trimmed)) != null) {
        out.add(_ContentParagraph(text: m!.group(1)!, type: _PType.subBullet));
      } else if ((m = _bullet.firstMatch(stripped)) != null) {
        out.add(_ContentParagraph(text: m!.group(1)!, type: _PType.bullet));
      } else if ((m = _ordered.firstMatch(stripped)) != null) {
        numberedCounter++;
        out.add(_ContentParagraph(
          text: m!.group(2)!,
          type: _PType.numbered,
          number: numberedCounter,
        ));
      } else if ((m = _boldLine.firstMatch(stripped)) != null) {
        out.add(_ContentParagraph(text: m!.group(1)!, type: _PType.boldLine));
      } else {
        out.add(_ContentParagraph(text: stripped, type: _PType.normal));
      }
    }

    return out;
  }

  // ---------------------------------------------------------------------------
  // Rich text (inline bold / italic)
  // ---------------------------------------------------------------------------

  static final _inlineToken = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');

  pw.Widget _richText(
    String text, {
    double fontSize = _bodyFontSize,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final spans = <pw.InlineSpan>[];
    int cursor = 0;

    for (final match in _inlineToken.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(pw.TextSpan(
          text: text.substring(cursor, match.start),
          style: pw.TextStyle(fontSize: fontSize),
        ));
      }

      if (match.group(1) != null) {
        spans.add(pw.TextSpan(
          text: match.group(1)!,
          style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        spans.add(pw.TextSpan(
          text: match.group(2)!,
          style: pw.TextStyle(fontSize: fontSize, fontStyle: pw.FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        spans.add(pw.TextSpan(
          text: match.group(3)!,
          style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey800),
        ));
      }
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(pw.TextSpan(
        text: text.substring(cursor),
        style: pw.TextStyle(fontSize: fontSize),
      ));
    }

    if (spans.isEmpty) {
      return pw.Text(text, style: pw.TextStyle(fontSize: fontSize), textAlign: align);
    }

    return pw.RichText(
      text: pw.TextSpan(children: spans),
      textAlign: align,
    );
  }

  // ---------------------------------------------------------------------------
  // Paragraph renderer
  // ---------------------------------------------------------------------------

  pw.Widget _buildParagraph(_ContentParagraph p) {
    switch (p.type) {
      case _PType.space:
        return pw.SizedBox(height: 3);

      case _PType.separator:
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        );

      case _PType.h1:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                p.text,
                style: pw.TextStyle(
                  fontSize: _h1Size,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(color: _primary, thickness: 0.8),
            ],
          ),
        );

      case _PType.h2:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
          child: pw.Text(
            p.text,
            style: pw.TextStyle(
              fontSize: _h2Size,
              fontWeight: pw.FontWeight.bold,
              color: _primary,
            ),
          ),
        );

      case _PType.h3:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, bottom: 1),
          child: pw.Text(
            p.text,
            style: pw.TextStyle(
              fontSize: _h3Size,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        );

      case _PType.bullet:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10, bottom: 1),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 10,
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Container(
                  width: 3,
                  height: 3,
                  decoration: const pw.BoxDecoration(
                    color: _primary,
                    shape: pw.BoxShape.circle,
                  ),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(child: _richText(p.text)),
            ],
          ),
        );

      case _PType.subBullet:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 22, bottom: 1),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 10,
                child: pw.Text(
                  '-',
                  style: pw.TextStyle(
                    fontSize: _bodyFontSize - 0.5,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(
                child: _richText(p.text, fontSize: _bodyFontSize - 0.5),
              ),
            ],
          ),
        );

      case _PType.numbered:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10, bottom: 1),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 16,
                child: pw.Text(
                  '${p.number}.',
                  style: pw.TextStyle(
                    fontSize: _bodyFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(child: _richText(p.text)),
            ],
          ),
        );

      case _PType.boldLine:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3, bottom: 2),
          child: pw.Text(
            p.text,
            style: pw.TextStyle(
              fontSize: _bodyFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );

      case _PType.normal:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: _richText(p.text, align: pw.TextAlign.justify),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _fmt2(int n) => n.toString().padLeft(2, '0');
}

// =============================================================================
// Models
// =============================================================================

enum _PType {
  space,
  separator,
  h1,
  h2,
  h3,
  bullet,
  subBullet,
  numbered,
  boldLine,
  normal,
}

class _ContentParagraph {
  _ContentParagraph({required this.text, required this.type, this.number});

  final String text;
  final _PType type;
  final int? number;
}

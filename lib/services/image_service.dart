import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum ImageSourceType { camera, gallery }

class ImagePickResult {
  const ImagePickResult({
    required this.base64DataUrl,
    required this.bytes,
    required this.width,
    required this.height,
  });

  final String base64DataUrl;
  final Uint8List bytes;
  final int width;
  final int height;
}

class ImageService {
  static const int _maxDimension = 1024;
  static const int _jpegQuality = 75;
  static const int _maxBase64Bytes = 4 * 1024 * 1024; // 4 MB

  final _picker = ImagePicker();

  Future<ImagePickResult?> pickImage(ImageSourceType source) async {
    final xFile = await _picker.pickImage(
      source: source == ImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: _jpegQuality,
    );
    if (xFile == null) return null;

    final bytes = await xFile.readAsBytes();
    final decoded = await _decodeImageSize(bytes);
    final base64Str = base64Encode(bytes);

    if (base64Str.length > _maxBase64Bytes) {
      throw Exception(
        'A imagem é muito grande (>${(_maxBase64Bytes / 1024 / 1024).toStringAsFixed(0)} MB). '
        'Tente tirar a foto com menor resolução.',
      );
    }

    final dataUrl = 'data:image/jpeg;base64,$base64Str';

    return ImagePickResult(
      base64DataUrl: dataUrl,
      bytes: bytes,
      width: decoded.width,
      height: decoded.height,
    );
  }

  Future<({int width, int height})> _decodeImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final w = frame.image.width;
      final h = frame.image.height;
      frame.image.dispose();
      codec.dispose();
      return (width: w, height: h);
    } catch (_) {
      return (width: _maxDimension, height: _maxDimension);
    }
  }
}

import 'package:flutter/material.dart';

/// Paleta única do app. Use Theme.of(context).colorScheme nas telas.
class AppColors {
  static const Color primary = Color(0xFF1A2848);
  static const Color onPrimary = Colors.white;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFB00020);
  static const Color onError = Colors.white;

  /// Cor de destaque para dias de feriado no calendário (dentro da paleta azul/cinza).
  static const Color holiday = Color(0xFFE2E8F0);

  /// Cor para dias bloqueados pelo usuário (ex.: folga), distinta do feriado.
  static const Color blockedDay = Color(0xFFFEF3C7);

  const AppColors._();
}

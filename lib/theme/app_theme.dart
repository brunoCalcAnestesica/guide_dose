import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Espaçamento padronizado. Use em todas as telas.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Padding horizontal/vertical da tela (conteúdo principal).
  static const double screenPadding = 16;
  /// Espaço entre seções (ex.: entre cards).
  static const double sectionSpacing = 24;
  /// Padding interno de cards.
  static const double cardPadding = 12;
  /// Entre itens em listas.
  static const double listItemSpacing = 12;

  const AppSpacing._();
}

/// Raios de borda padronizados.
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(sm);
  static BorderRadius get input => BorderRadius.circular(sm);

  const AppRadius._();
}

/// Estilo padronizado das barras de título (AppBar e barras customizadas como Medicamentos).
class AppBarStyle {
  /// Altura fixa das barras para todas as telas (igual à AppBar padrão).
  static const double toolbarHeight = 56;

  /// Estilo do título: mesma fonte e tamanho em todas as barras.
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  const AppBarStyle._();
}

class AppTheme {
  static ColorScheme get _colorScheme => ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        error: AppColors.error,
        onError: AppColors.onError,
      );

  /// Tipografia única: mesma família em todo o app (padrão do sistema).
  static TextTheme get _textTheme => TextTheme(
        headlineMedium: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.surfaceVariant,
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          centerTitle: true,
          elevation: 2,
          toolbarHeight: AppBarStyle.toolbarHeight,
          titleTextStyle: AppBarStyle.titleStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            textStyle: _textTheme.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: AppRadius.input),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          labelStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
          hintStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          clipBehavior: Clip.antiAlias,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.onSurface,
          contentTextStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.surface),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.outline,
          thickness: 1,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.fuchsia: _NoAnimationPageTransitionsBuilder(),
          },
        ),
      );
}

/// Remove animações entre mudanças de tela.
class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

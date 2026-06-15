import 'package:flutter/material.dart';

/// Tema visual do app, centralizado num lugar só.
///
/// Manter cores e estilos aqui (em vez de espalhados pelas telas) deixa a
/// interface consistente e fácil de ajustar — conta pontos de usabilidade.
class AppTheme {
  static const Color corPrincipal = Color(0xFF3F51B5); // índigo
  static const Color corAtrasada = Color(0xFFE53935); // vermelho
  static const Color corAVencer = Color(0xFFF9A825); // âmbar
  static const Color corConcluida = Color(0xFF43A047); // verde

  static ThemeData get tema {
    final base = ColorScheme.fromSeed(seedColor: corPrincipal);
    return ThemeData(
      colorScheme: base,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrincipal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

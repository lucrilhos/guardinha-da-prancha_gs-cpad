import 'package:flutter/material.dart';

import 'cores.dart';
import 'espacos.dart';

/// Os três temas do app: claro, escuro e alto contraste.
class TemaApp {
  const TemaApp._();

  static ThemeData claro() => _base(
        ColorScheme.fromSeed(
          seedColor: CoresApp.petroleo,
          primary: CoresApp.petroleo,
          onPrimary: Colors.white,
          secondary: CoresApp.ambar,
          onSecondary: CoresApp.textoEscuro,
          surface: Colors.white,
          onSurface: CoresApp.textoEscuro,
        ),
        fundo: CoresApp.fundoClaro,
      );

  static ThemeData escuro() => _base(
        ColorScheme.fromSeed(
          seedColor: CoresApp.petroleo,
          brightness: Brightness.dark,
          primary: CoresApp.petroleoClaro,
          onPrimary: CoresApp.textoEscuro,
          secondary: CoresApp.ambar,
          onSecondary: CoresApp.textoEscuro,
          surface: CoresApp.superficieEscura,
          onSurface: const Color(0xFFE6EEF0),
        ),
        fundo: CoresApp.fundoEscuro,
      );

  /// Preto no branco, bordas fortes: para baixa visão e sol forte na tela.
  static ThemeData altoContraste() => _base(
        const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF00313A),
          onPrimary: Colors.white,
          secondary: Color(0xFF00313A),
          onSecondary: Colors.white,
          error: Color(0xFF9B0000),
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          onSurfaceVariant: Colors.black,
          outline: Colors.black,
          outlineVariant: Colors.black,
          primaryContainer: Color(0xFF00313A),
          onPrimaryContainer: Colors.white,
          secondaryContainer: Color(0xFFFFE082),
          onSecondaryContainer: Colors.black,
        ),
        fundo: Colors.white,
        bordaForte: true,
      );

  static ThemeData _base(ColorScheme cores, {required Color fundo, bool bordaForte = false}) {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Espaco.raioPequeno),
      borderSide: BorderSide(color: cores.outline, width: bordaForte ? 2 : 1),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cores,
      scaffoldBackgroundColor: fundo,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surface,
        border: borda,
        enabledBorder: borda,
        contentPadding: const EdgeInsets.symmetric(horizontal: Espaco.m, vertical: Espaco.m),
      ),
    );
  }
}

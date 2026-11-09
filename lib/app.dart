import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/tema/tema_app.dart';
import 'estado/preferencias_provider.dart';
import 'rotas.dart';

class GuardinhaApp extends StatelessWidget {
  const GuardinhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasProvider>();

    return MaterialApp(
      title: 'Guardinha da Prancha',
      debugShowCheckedModeBanner: false,
      theme: preferencias.altoContraste ? TemaApp.altoContraste() : TemaApp.claro(),
      darkTheme: preferencias.altoContraste ? TemaApp.altoContraste() : TemaApp.escuro(),
      themeMode: preferencias.modoTema,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: Rotas.inicio,
      routes: Rotas.mapa,
      // tamanho de fonte: o do sistema multiplicado pelo escolhido em Ajustes (limite de 200%)
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final escala = (mq.textScaler.scale(1) * preferencias.escalaFonte).clamp(1.0, 2.0).toDouble();
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(escala)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

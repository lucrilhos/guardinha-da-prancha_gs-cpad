import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'dados/fontes/armazenamento_local.dart';
import 'estado/ocorrencias_provider.dart';
import 'estado/preferencias_provider.dart';
import 'estado/territorio_provider.dart';

/// Ponto de entrada: abre o armazenamento do aparelho e entrega os estados globais
/// (providers) para todas as telas.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final armazenamento = ArmazenamentoLocal(await SharedPreferences.getInstance());
  final preferencias = PreferenciasProvider(armazenamento);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: preferencias),
        ChangeNotifierProvider(
          create: (_) => TerritorioProvider(preferencias: preferencias, armazenamento: armazenamento),
        ),
        ChangeNotifierProvider(create: (_) => OcorrenciasProvider(armazenamento)),
      ],
      child: const GuardinhaApp(),
    ),
  );
}

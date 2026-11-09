import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../estado/preferencias_provider.dart';
import '../consentimento/consentimento_tela.dart';
import 'shell_tela.dart';

/// Decide a primeira tela: sem consentimento -> tela de consentimento; com -> app.
class PortaoInicial extends StatelessWidget {
  const PortaoInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final consentiu = context.select<PreferenciasProvider, bool>((p) => p.consentiu);
    return consentiu ? const ShellTela() : const ConsentimentoTela();
  }
}

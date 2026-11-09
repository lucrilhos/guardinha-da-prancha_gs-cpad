import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../estado/territorio_provider.dart';
import '../ajustes/ajustes_tela.dart';
import '../alertas/alertas_tela.dart';
import '../inicio/inicio_tela.dart';
import '../ocorrencias/ocorrencias_tela.dart';

/// Estrutura com a barra de navegação inferior (4 abas).
/// A aba selecionada é ESTADO LOCAL (só esta tela precisa saber).
class ShellTela extends StatefulWidget {
  const ShellTela({super.key});

  @override
  State<ShellTela> createState() => _ShellTelaState();
}

class _ShellTelaState extends State<ShellTela> {
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    // busca os dados assim que a primeira tela aparece
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final territorio = context.read<TerritorioProvider>();
      if (territorio.status == StatusCarga.inicial) territorio.carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAlertas = context.select<TerritorioProvider, int>((t) => t.alertas.length);

    return Scaffold(
      body: IndexedStack(
        index: _aba,
        children: [
          InicioTela(aoVerTodosAlertas: () => setState(() => _aba = 1)),
          const AlertasTela(),
          const OcorrenciasTela(),
          const AjustesTela(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (indice) => setState(() => _aba = indice),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalAlertas > 0,
              label: Text('$totalAlertas'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alertas',
            tooltip: '$totalAlertas alertas ativos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: 'Ocorrências',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../componentes/aviso_decisao_humana.dart';
import '../../componentes/corpo_territorio.dart';
import '../../componentes/estados_tela.dart';
import '../../componentes/item_alerta.dart';
import '../../core/tema/espacos.dart';
import '../../dados/modelos/indicador.dart';

/// Lista de todos os alertas, com filtro por painel.
/// O filtro escolhido é ESTADO LOCAL (só esta tela usa); os alertas vêm do estado GLOBAL.
class AlertasTela extends StatefulWidget {
  const AlertasTela({super.key});

  @override
  State<AlertasTela> createState() => _AlertasTelaState();
}

class _AlertasTelaState extends State<AlertasTela> {
  Dominio? _filtro; // null = todos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final alertas = _filtro == null ? territorio.alertas : territorio.alertasDe(_filtro!);
          return [
            const AvisoDecisaoHumana(compacto: true),
            const SizedBox(height: Espaco.m),
            Wrap(
              spacing: Espaco.p,
              runSpacing: Espaco.p,
              children: [
                ChoiceChip(
                  label: Text('Todos (${territorio.alertas.length})'),
                  selected: _filtro == null,
                  onSelected: (_) => setState(() => _filtro = null),
                ),
                for (final dominio in Dominio.values)
                  ChoiceChip(
                    label: Text('${dominio.rotulo} (${territorio.alertasDe(dominio).length})'),
                    selected: _filtro == dominio,
                    onSelected: (_) => setState(() => _filtro = dominio),
                  ),
              ],
            ),
            const SizedBox(height: Espaco.m),
            if (alertas.isEmpty)
              const EstadoVazio(
                icone: Icons.notifications_off_outlined,
                titulo: 'Nenhum alerta aqui',
                mensagem: 'Os dados atuais não atingem nenhum limiar. Isso não garante ausência de risco: '
                    'continue atento aos avisos oficiais da Defesa Civil.',
                rolavel: false,
              )
            else
              for (final alerta in alertas)
                Padding(padding: const EdgeInsets.only(bottom: Espaco.p), child: ItemAlerta(alerta)),
          ];
        },
      ),
    );
  }
}

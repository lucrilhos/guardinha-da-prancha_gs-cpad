import 'package:flutter/material.dart';

import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/item_alerta.dart';
import '../../core/tema/espacos.dart';
import '../../dados/modelos/alerta.dart';

/// Bloco "Alertas deste painel", repetido nos três painéis.
class AlertasDoPainel extends StatelessWidget {
  const AlertasDoPainel({super.key, required this.alertas, required this.textoSemAlerta});

  final List<Alerta> alertas;
  final String textoSemAlerta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecaoTitulo('Alertas deste painel (${alertas.length})'),
        if (alertas.isEmpty)
          CartaoPadrao(child: Text(textoSemAlerta))
        else
          for (final alerta in alertas)
            Padding(padding: const EdgeInsets.only(bottom: Espaco.p), child: ItemAlerta(alerta)),
      ],
    );
  }
}

/// Linha pequena com a fonte do dado (transparência).
class TextoFonte extends StatelessWidget {
  const TextoFonte(this.fonte, {super.key});

  final String fonte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Espaco.m),
      child: Text('Fonte: $fonte', style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

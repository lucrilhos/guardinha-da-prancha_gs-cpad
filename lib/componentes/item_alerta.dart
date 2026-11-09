import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/tema/cores.dart';
import '../core/tema/espacos.dart';
import '../core/utils/formatadores.dart';
import '../dados/modelos/alerta.dart';
import '../estado/preferencias_provider.dart';
import '../rotas.dart';
import 'cartao_padrao.dart';
import 'chip_nivel.dart';

/// Linha de alerta usada no Início, na lista de Alertas e no detalhe do indicador.
/// Toque -> abre o detalhe do alerta (rota nomeada com o id como parâmetro).
class ItemAlerta extends StatelessWidget {
  const ItemAlerta(this.alerta, {super.key});

  final Alerta alerta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final avaliado = context.watch<PreferenciasProvider>().foiAvaliado(alerta.id);
    final rotulo = 'Alerta ${alerta.nivel.rotulo}: ${alerta.titulo}. ${alerta.resumo} '
        'Confiança ${alerta.rotuloConfianca}. ${avaliado ? 'Já avaliado por um responsável.' : ''} '
        'Toque para ver a justificativa.';

    return CartaoPadrao(
      rotuloAcessivel: rotulo,
      aoTocar: () => Navigator.pushNamed(context, Rotas.alerta, arguments: alerta.id),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: CoresApp.doNivel(alerta.nivel)), // faixa colorida do nível
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Espaco.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: Espaco.p,
                      runSpacing: Espaco.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ChipNivel(alerta.nivel),
                        Text('${alerta.dominio.rotulo} · ${formatarHora(alerta.geradoEm)}',
                            style: tema.textTheme.labelSmall),
                        if (avaliado)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.verified_outlined, size: 16, color: tema.colorScheme.primary),
                            const SizedBox(width: Espaco.xs),
                            Text('Avaliado', style: tema.textTheme.labelSmall),
                          ]),
                      ],
                    ),
                    const SizedBox(height: Espaco.p),
                    Text(alerta.titulo, style: tema.textTheme.titleMedium),
                    const SizedBox(height: Espaco.xs),
                    Text(alerta.resumo, style: tema.textTheme.bodyMedium),
                    const SizedBox(height: Espaco.p),
                    Text('Confiança: ${alerta.rotuloConfianca} (${formatarPorcentagem(alerta.confianca)})',
                        style: tema.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

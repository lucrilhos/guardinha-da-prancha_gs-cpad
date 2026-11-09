import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/basicos.dart';
import '../../componentes/cartao_indicador.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/corpo_territorio.dart';
import '../../componentes/estados_tela.dart';
import '../../componentes/grafico_serie.dart';
import '../../componentes/item_alerta.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/indicador.dart';
import '../../estado/preferencias_provider.dart';
import '../../logica/descricoes.dart';
import '../../rotas.dart';

/// Detalhe de UM indicador. Recebe o id pela rota nomeada (Rotas.indicador).
class IndicadorDetalheTela extends StatelessWidget {
  const IndicadorDetalheTela({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Rotas.argumento(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do indicador')),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final indicador = territorio.indicadorPorId(id);
          if (indicador == null) {
            return const [
              EstadoVazio(
                icone: Icons.search_off,
                titulo: 'Indicador não encontrado',
                mensagem: 'Os dados foram atualizados e este indicador não está mais disponível.',
                rolavel: false,
              ),
            ];
          }

          final tema = Theme.of(context);
          final limiares = context.watch<PreferenciasProvider>().limiares;
          final alertas = territorio.alertasDoIndicador(indicador.id);
          final atual = indicador.valorAtual;

          return [
            Semantics(header: true, child: Text(indicador.titulo, style: tema.textTheme.headlineSmall)),
            Text(indicador.local, style: tema.textTheme.bodyMedium),
            const SizedBox(height: Espaco.m),
            CartaoIndicador(
              titulo: 'Valor mais recente',
              icone: Icons.speed,
              valor: atual == null
                  ? '—'
                  : formatarValor(atual, indicador.unidade, casas: indicador.casasDecimais),
              detalhe: [
                if (indicador.atualizadoEm != null) 'Em ${formatarDataHora(indicador.atualizadoEm!)}',
                Descricoes.tendencia(indicador),
              ].join(' · '),
              nivel: Descricoes.limitesDoGrafico(indicador, limiares).isEmpty
                  ? null
                  : Descricoes.nivelPrevisto(indicador, limiares),
            ),
            if (indicador.sintetico) ...[
              const SizedBox(height: Espaco.m),
              const CartaoPadrao(
                child: Row(
                  children: [
                    Icon(Icons.science_outlined),
                    SizedBox(width: Espaco.p + Espaco.xs),
                    Expanded(child: Text('Dado SINTÉTICO, gerado pelo app. Não é uma medição real.')),
                  ],
                ),
              ),
            ],
            const SecaoTitulo('Histórico e previsão'),
            CartaoPadrao(
              child: GraficoSerie(
                indicador: indicador,
                emDias: indicador.dominio == Dominio.reservatorios,
                altura: 260,
                limites: Descricoes.limitesDoGrafico(indicador, limiares),
              ),
            ),
            const SecaoTitulo('Como este número é calculado'),
            CartaoPadrao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(indicador.comoCalculamos),
                  const SizedBox(height: Espaco.p),
                  Text('Fonte: ${indicador.fonte}', style: tema.textTheme.bodySmall),
                ],
              ),
            ),
            SecaoTitulo('Alertas deste indicador (${alertas.length})'),
            if (alertas.isEmpty)
              const CartaoPadrao(child: Text('Nenhum alerta para este indicador agora.'))
            else
              for (final alerta in alertas)
                Padding(padding: const EdgeInsets.only(bottom: Espaco.p), child: ItemAlerta(alerta)),
          ];
        },
      ),
    );
  }
}

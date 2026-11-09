import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/tema/cores.dart';
import '../core/tema/espacos.dart';
import '../core/utils/formatadores.dart';
import '../dados/modelos/indicador.dart';
import '../dados/modelos/limiares.dart';

/// Gráfico de linha reutilizável: histórico (linha cheia) + previsão (linha tracejada)
/// + linhas de limite. O eixo X é contado a partir do último valor medido ("agora").
class GraficoSerie extends StatelessWidget {
  const GraficoSerie({
    super.key,
    required this.indicador,
    this.limites = const [],
    this.emDias = false,
    this.altura = 220,
    this.ultimosPontos,
  });

  final Indicador indicador;
  final List<LinhaLimite> limites;

  /// false = eixo em horas (clima, córregos); true = eixo em dias (reservatórios).
  final bool emDias;
  final double altura;

  /// Mostrar só os N últimos pontos do histórico (null = todos).
  final int? ultimosPontos;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textoEixo = Theme.of(context).textTheme.labelSmall;
    final historico = ultimosPontos == null || indicador.historico.length <= ultimosPontos!
        ? indicador.historico
        : indicador.historico.sublist(indicador.historico.length - ultimosPontos!);

    if (historico.isEmpty) {
      return SizedBox(height: altura, child: const Center(child: Text('Sem dados para o gráfico.')));
    }

    final referencia = historico.last.momento;
    double posicaoX(DateTime momento) {
      final minutos = momento.difference(referencia).inMinutes;
      return emDias ? minutos / (60 * 24) : minutos / 60;
    }

    final pontosHistorico = [for (final p in historico) FlSpot(posicaoX(p.momento), p.valor)];
    final pontosPrevisao = [
      FlSpot(0, historico.last.valor), // liga a previsão ao último valor medido
      for (final p in indicador.previsao) FlSpot(posicaoX(p.momento), p.valor),
    ];

    final todosValores = [
      ...historico.map((p) => p.valor),
      ...indicador.previsao.map((p) => p.valor),
      ...limites.map((l) => l.valor),
    ];
    final maiorValor = todosValores.reduce(max);
    final menorValor = todosValores.reduce(min);
    final folga = max((maiorValor - menorValor) * 0.1, 0.5);
    final minY = max(0.0, menorValor - folga);
    final maxY = maiorValor + folga;
    final minX = pontosHistorico.first.x;
    final maxX = indicador.previsao.isEmpty ? 0.0 : pontosPrevisao.last.x;
    final intervaloX = max(1.0, ((maxX - minX) / 4).roundToDouble());

    return Semantics(
      label: _descricaoAcessivel(),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: altura,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: cores.outlineVariant, strokeWidth: 0.6),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (valor, meta) => Padding(
                        padding: const EdgeInsets.only(right: Espaco.xs),
                        child: Text(formatarNumero(valor, casas: maxY < 10 ? 1 : 0),
                            style: textoEixo, textAlign: TextAlign.right),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: intervaloX,
                      getTitlesWidget: (valor, meta) => Padding(
                        padding: const EdgeInsets.only(top: Espaco.xs),
                        child: Text(_rotuloX(valor), style: textoEixo),
                      ),
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    for (final limite in limites)
                      HorizontalLine(
                        y: limite.valor,
                        color: CoresApp.doNivel(limite.nivel),
                        strokeWidth: 1.5,
                        dashArray: [6, 4],
                      ),
                  ],
                  verticalLines: [
                    if (indicador.previsao.isNotEmpty)
                      VerticalLine(x: 0, color: cores.outline, strokeWidth: 1, dashArray: [2, 3]),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: pontosHistorico,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: cores.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: cores.primary.withValues(alpha: 0.12)),
                  ),
                  if (indicador.previsao.isNotEmpty)
                    LineChartBarData(
                      spots: pontosPrevisao,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: cores.secondary,
                      barWidth: 3,
                      dashArray: [8, 5],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Espaco.p),
          _Legenda(temPrevisao: indicador.previsao.isNotEmpty, limites: limites, unidade: indicador.unidade),
        ],
      ),
    );
  }

  String _rotuloX(double valor) {
    final n = valor.round();
    if (n == 0) return 'agora';
    final sufixo = emDias ? 'd' : 'h';
    return n > 0 ? '+$n$sufixo' : '$n$sufixo';
  }

  /// O que o leitor de tela fala no lugar do desenho.
  String _descricaoAcessivel() {
    final atual = indicador.valorAtual;
    final partes = <String>['Gráfico de ${indicador.titulo}.'];
    if (atual != null) {
      partes.add('Valor atual: ${formatarValor(atual, indicador.unidade, casas: indicador.casasDecimais)}.');
    }
    if (indicador.previsao.isNotEmpty) {
      final maior = indicador.previsao.map((p) => p.valor).reduce(max);
      partes.add('Maior valor previsto: ${formatarValor(maior, indicador.unidade, casas: indicador.casasDecimais)}.');
    }
    for (final l in limites) {
      partes.add('Limite de ${l.nivel.rotulo}: ${formatarValor(l.valor, indicador.unidade)}.');
    }
    return partes.join(' ');
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.temPrevisao, required this.limites, required this.unidade});

  final bool temPrevisao;
  final List<LinhaLimite> limites;
  final String unidade;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Espaco.m,
      runSpacing: Espaco.xs,
      children: [
        _ItemLegenda(cor: cores.primary, texto: 'Medido ($unidade)'),
        if (temPrevisao) _ItemLegenda(cor: cores.secondary, texto: 'Previsão', tracejado: true),
        for (final l in limites) _ItemLegenda(cor: CoresApp.doNivel(l.nivel), texto: l.nivel.rotulo, tracejado: true),
      ],
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  const _ItemLegenda({required this.cor, required this.texto, this.tracejado = false});

  final Color cor;
  final String texto;
  final bool tracejado;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: tracejado ? 2 : 4,
          color: cor,
        ),
        const SizedBox(width: Espaco.xs),
        Text(texto, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

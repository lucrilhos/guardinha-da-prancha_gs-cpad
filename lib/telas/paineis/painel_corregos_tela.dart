import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/banner_fonte_dados.dart';
import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/chip_nivel.dart';
import '../../componentes/corpo_territorio.dart';
import '../../componentes/grafico_serie.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/indicador.dart';
import '../../dados/modelos/limiares.dart';
import '../../estado/preferencias_provider.dart';
import '../../logica/descricoes.dart';
import '../../rotas.dart';
import 'alertas_do_painel.dart';

/// DASHBOARD 2 — Córregos: nível de 3 córregos do ABC (dados sintéticos) com previsão de 6 horas.
class PainelCorregosTela extends StatelessWidget {
  const PainelCorregosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel dos córregos')),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final limiares = context.watch<PreferenciasProvider>().limiares;
          return [
            const BannerFonteDados(),
            const SizedBox(height: Espaco.m),
            const CartaoPadrao(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: Espaco.p + Espaco.xs),
                  Expanded(
                    child: Text('Leituras SIMULADAS: não há sensores reais nestes córregos. O nível é calculado '
                        'a partir da chuva (o córrego sobe de 1 a 6 horas depois que chove).'),
                  ),
                ],
              ),
            ),
            const SecaoTitulo('Nível agora e nas próximas 6 horas'),
            for (final corrego in territorio.corregos)
              Padding(
                padding: const EdgeInsets.only(bottom: Espaco.m),
                child: _CartaoCorrego(corrego: corrego, limiares: limiares),
              ),
            AlertasDoPainel(
              alertas: territorio.alertasDe(Dominio.corregos),
              textoSemAlerta: 'Nenhum córrego deve atingir o limiar de ATENÇÃO nas próximas 6 horas.',
            ),
          ];
        },
      ),
    );
  }
}

class _CartaoCorrego extends StatelessWidget {
  const _CartaoCorrego({required this.corrego, required this.limiares});

  final Indicador corrego;
  final Limiares limiares;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final atual = corrego.valorAtual ?? 0;
    final maiorPrevisto = corrego.previsao.isEmpty ? atual : corrego.previsao.map((p) => p.valor).reduce(max);
    final nivel = Descricoes.nivelPrevisto(corrego, limiares);

    return CartaoPadrao(
      aoTocar: () => Navigator.pushNamed(context, Rotas.indicador, arguments: corrego.id),
      rotuloAcessivel: '${corrego.titulo}, ${corrego.local}. Nível agora ${formatarValor(atual, 'm', casas: 2)}, '
          'máximo previsto ${formatarValor(maiorPrevisto, 'm', casas: 2)}. Nível ${nivel.rotulo}. '
          'Toque para ver detalhes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(corrego.titulo, style: tema.textTheme.titleMedium)),
              ChipNivel(nivel),
            ],
          ),
          Text(corrego.local, style: tema.textTheme.bodySmall),
          const SizedBox(height: Espaco.p),
          Wrap(
            spacing: Espaco.g,
            runSpacing: Espaco.xs,
            children: [
              Text('Agora: ${formatarValor(atual, 'm', casas: 2)}', style: tema.textTheme.titleSmall),
              Text('Máx. previsto: ${formatarValor(maiorPrevisto, 'm', casas: 2)}', style: tema.textTheme.titleSmall),
              Text(Descricoes.tendencia(corrego), style: tema.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: Espaco.m),
          GraficoSerie(
            indicador: corrego,
            ultimosPontos: 24,
            altura: 150,
            limites: Descricoes.limitesDoGrafico(corrego, limiares),
          ),
        ],
      ),
    );
  }
}

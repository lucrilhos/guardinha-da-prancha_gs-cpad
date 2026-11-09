import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/banner_fonte_dados.dart';
import '../../componentes/basicos.dart';
import '../../componentes/cartao_indicador.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/corpo_territorio.dart';
import '../../componentes/grafico_serie.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/indicador.dart';
import '../../estado/preferencias_provider.dart';
import '../../rotas.dart';
import 'alertas_do_painel.dart';

/// DASHBOARD 1 — Clima: chuva (medida e prevista) e temperatura, com dados reais da Open-Meteo.
class PainelClimaTela extends StatelessWidget {
  const PainelClimaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de clima')),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final limiares = context.watch<PreferenciasProvider>().limiares;
          final chuva = territorio.indicadorPorId('clima-chuva');
          final temperatura = territorio.indicadorPorId('clima-temperatura');
          final probabilidade = territorio.indicadorPorId('clima-probabilidade');
          final prevista24h = territorio.somaChuva24h(futura: true);

          PontoSerie? pico;
          for (final p in chuva?.previsao ?? const <PontoSerie>[]) {
            if (pico == null || p.valor > pico.valor) pico = p;
          }
          double? maiorProbabilidade;
          for (final p in probabilidade?.previsao.take(24) ?? const <PontoSerie>[]) {
            if (maiorProbabilidade == null || p.valor > maiorProbabilidade) maiorProbabilidade = p.valor;
          }

          return [
            const BannerFonteDados(),
            const SizedBox(height: Espaco.m),
            GradeResponsiva(
              children: [
                CartaoIndicador(
                  titulo: 'Chuva prevista – próximas 24 h',
                  icone: Icons.thunderstorm_outlined,
                  valor: formatarValor(prevista24h, 'mm'),
                  detalhe: 'ATENÇÃO a partir de ${formatarValor(limiares.chuva24h.atencao, 'mm', casas: 0)}',
                  nivel: limiares.chuva24h.classificar(prevista24h),
                  aoTocar: () => Navigator.pushNamed(context, Rotas.indicador, arguments: 'clima-chuva'),
                ),
                CartaoIndicador(
                  titulo: 'Chuva nas últimas 24 h',
                  icone: Icons.water_drop_outlined,
                  valor: formatarValor(territorio.somaChuva24h(futura: false), 'mm'),
                  detalhe: 'Solo molhado escoa mais água para ruas e córregos',
                ),
                CartaoIndicador(
                  titulo: 'Hora mais chuvosa prevista',
                  icone: Icons.schedule,
                  valor: pico == null ? '—' : formatarValor(pico.valor, 'mm'),
                  detalhe: pico == null ? 'Sem previsão disponível' : 'Em ${formatarDataHora(pico.momento)}',
                ),
                CartaoIndicador(
                  titulo: 'Temperatura agora',
                  icone: Icons.thermostat,
                  valor: temperatura?.valorAtual == null ? '—' : formatarValor(temperatura!.valorAtual!, '°C'),
                  detalhe: temperatura == null ? null : 'Toque para ver as próximas horas',
                  aoTocar: () => Navigator.pushNamed(context, Rotas.indicador, arguments: 'clima-temperatura'),
                ),
                CartaoIndicador(
                  titulo: 'Maior chance de chuva (24 h)',
                  icone: Icons.percent,
                  valor: maiorProbabilidade == null ? '—' : '${maiorProbabilidade.round()}%',
                  detalhe: 'Usada no cálculo da confiança do alerta',
                  aoTocar: () => Navigator.pushNamed(context, Rotas.indicador, arguments: 'clima-probabilidade'),
                ),
              ],
            ),
            if (chuva != null) ...[
              const SecaoTitulo('Chuva hora a hora'),
              CartaoPadrao(child: GraficoSerie(indicador: chuva)),
              TextoFonte(chuva.fonte),
            ],
            if (temperatura != null) ...[
              const SecaoTitulo('Temperatura'),
              CartaoPadrao(child: GraficoSerie(indicador: temperatura, altura: 180)),
            ],
            AlertasDoPainel(
              alertas: territorio.alertasDe(Dominio.clima),
              textoSemAlerta: 'A chuva prevista para as próximas 24 horas está abaixo do limiar de ATENÇÃO.',
            ),
          ];
        },
      ),
    );
  }
}

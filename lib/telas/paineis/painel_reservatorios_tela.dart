import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

/// DASHBOARD 3 — Reservatórios: volume dos mananciais (dados reais da Sabesp) + projeção de 30 dias.
class PainelReservatoriosTela extends StatelessWidget {
  const PainelReservatoriosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel dos reservatórios')),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final limiares = context.watch<PreferenciasProvider>().limiares;
          final cenarioDemonstracao = territorio.cenarioDemonstracao;
          return [
            CartaoPadrao(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(cenarioDemonstracao ? Icons.science_outlined : Icons.offline_pin_outlined),
                  const SizedBox(width: Espaco.p + Espaco.xs),
                  Expanded(
                    child: Text(cenarioDemonstracao
                        ? 'MODO DEMONSTRAÇÃO: o Sistema Integrado está com uma estiagem fictícia nos últimos 30 dias.'
                        : 'Dados públicos da Sabesp guardados no app: este painel funciona mesmo sem internet.'),
                  ),
                ],
              ),
            ),
            const SecaoTitulo('Volume útil e projeção de 30 dias'),
            for (final reservatorio in territorio.reservatorios)
              Padding(
                padding: const EdgeInsets.only(bottom: Espaco.m),
                child: _CartaoReservatorio(reservatorio: reservatorio, limiares: limiares),
              ),
            AlertasDoPainel(
              alertas: territorio.alertasDe(Dominio.reservatorios),
              textoSemAlerta: 'Os volumes e as projeções de 30 dias estão acima do limiar de ATENÇÃO.',
            ),
            if (territorio.reservatorios.isNotEmpty) TextoFonte(territorio.reservatorios.first.fonte),
          ];
        },
      ),
    );
  }
}

class _CartaoReservatorio extends StatelessWidget {
  const _CartaoReservatorio({required this.reservatorio, required this.limiares});

  final Indicador reservatorio;
  final Limiares limiares;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final atual = reservatorio.valorAtual ?? 0;
    final projetado = reservatorio.previsao.isEmpty ? null : reservatorio.previsao.last;
    final nivel = Descricoes.nivelPrevisto(reservatorio, limiares);

    return CartaoPadrao(
      aoTocar: () => Navigator.pushNamed(context, Rotas.indicador, arguments: reservatorio.id),
      rotuloAcessivel: '${reservatorio.titulo}. Volume ${formatarValor(atual, '%')}. '
          '${projetado == null ? '' : 'Projeção para ${formatarData(projetado.momento)}: ${formatarValor(projetado.valor, '%')}. '}'
          'Nível ${nivel.rotulo}. Toque para ver detalhes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(reservatorio.titulo, style: tema.textTheme.titleMedium)),
              ChipNivel(nivel),
            ],
          ),
          Text(reservatorio.local, style: tema.textTheme.bodySmall),
          const SizedBox(height: Espaco.p),
          Wrap(
            spacing: Espaco.g,
            runSpacing: Espaco.xs,
            children: [
              Text('Hoje: ${formatarValor(atual, '%')}', style: tema.textTheme.titleSmall),
              if (projetado != null)
                Text('Em ${formatarData(projetado.momento)}: ${formatarValor(projetado.valor, '%')}',
                    style: tema.textTheme.titleSmall),
              Text(Descricoes.tendencia(reservatorio), style: tema.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: Espaco.m),
          GraficoSerie(
            indicador: reservatorio,
            emDias: true,
            ultimosPontos: 90,
            altura: 170,
            limites: Descricoes.limitesDoGrafico(reservatorio, limiares),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/aviso_decisao_humana.dart';
import '../../componentes/banner_fonte_dados.dart';
import '../../componentes/basicos.dart';
import '../../componentes/cartao_indicador.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/corpo_territorio.dart';
import '../../componentes/item_alerta.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/indicador.dart';
import '../../estado/ocorrencias_provider.dart';
import '../../estado/territorio_provider.dart';
import '../../rotas.dart';

/// Visão geral: alertas mais graves, atalhos para os 3 painéis e o impacto social.
class InicioTela extends StatelessWidget {
  const InicioTela({super.key, required this.aoVerTodosAlertas});

  /// Troca para a aba Alertas (quem controla as abas é a ShellTela).
  final VoidCallback aoVerTodosAlertas;

  @override
  Widget build(BuildContext context) {
    final carregando = context.select<TerritorioProvider, bool>((t) => t.status == StatusCarga.carregando);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            LogoApp(tamanho: 32),
            SizedBox(width: Espaco.p),
            Flexible(child: Text('Guardinha da Prancha', overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: carregando ? null : () => context.read<TerritorioProvider>().carregar(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final tema = Theme.of(context);
          final alertas = territorio.alertas;
          final rioGrande = territorio.indicadorPorId('reservatorio-rio-grande');
          final corrego = territorio.corregoMaisAlto;

          return [
            Text('Água e chuva no ABC', style: tema.textTheme.headlineSmall),
            const SizedBox(height: Espaco.xs),
            Text('Painel de antecipação para a Defesa Civil e para os moradores.', style: tema.textTheme.bodyMedium),
            const SizedBox(height: Espaco.m),
            const BannerFonteDados(),
            const SizedBox(height: Espaco.m),
            const AvisoDecisaoHumana(compacto: true),

            SecaoTitulo(
              'Alertas ativos (${alertas.length})',
              acao: alertas.isEmpty ? null : TextButton(onPressed: aoVerTodosAlertas, child: const Text('Ver todos')),
            ),
            if (alertas.isEmpty)
              const CartaoPadrao(
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: Espaco.p + Espaco.xs),
                    Expanded(
                      child: Text('Nenhum alerta no momento. Isso não garante ausência de risco: '
                          'continue atento aos avisos oficiais.'),
                    ),
                  ],
                ),
              )
            else
              for (final alerta in alertas.take(3))
                Padding(padding: const EdgeInsets.only(bottom: Espaco.p), child: ItemAlerta(alerta)),

            const SecaoTitulo('Painéis do território'),
            GradeResponsiva(
              children: [
                CartaoIndicador(
                  titulo: Dominio.clima.rotulo,
                  icone: Icons.thunderstorm_outlined,
                  valor: '${formatarValor(territorio.somaChuva24h(futura: true), 'mm')} em 24 h',
                  detalhe: 'Chuva prevista para as próximas 24 horas',
                  nivel: territorio.nivelMaximo(Dominio.clima),
                  aoTocar: () => Navigator.pushNamed(context, Rotas.painelClima),
                ),
                CartaoIndicador(
                  titulo: Dominio.corregos.rotulo,
                  icone: Icons.water_outlined,
                  valor: corrego?.valorAtual == null ? '—' : formatarValor(corrego!.valorAtual!, 'm', casas: 2),
                  detalhe: corrego == null ? null : 'Maior nível agora: ${corrego.titulo}',
                  nivel: territorio.nivelMaximo(Dominio.corregos),
                  aoTocar: () => Navigator.pushNamed(context, Rotas.painelCorregos),
                ),
                CartaoIndicador(
                  titulo: Dominio.reservatorios.rotulo,
                  icone: Icons.waves_outlined,
                  valor: rioGrande?.valorAtual == null ? '—' : formatarValor(rioGrande!.valorAtual!, '%'),
                  detalhe: 'Volume do Sistema Rio Grande (abastece o ABC)',
                  nivel: territorio.nivelMaximo(Dominio.reservatorios),
                  aoTocar: () => Navigator.pushNamed(context, Rotas.painelReservatorios),
                ),
              ],
            ),

            const SecaoTitulo('Impacto social'),
            const _CartaoImpactoSocial(),
          ];
        },
      ),
    );
  }
}

/// Indicadores de BENEFÍCIO SOCIAL: quanto o app ajuda as pessoas, não só quão bem ele calcula.
class _CartaoImpactoSocial extends StatelessWidget {
  const _CartaoImpactoSocial();

  @override
  Widget build(BuildContext context) {
    final territorio = context.watch<TerritorioProvider>();
    final ocorrencias = context.watch<OcorrenciasProvider>().total;
    final antecedencia = territorio.antecedenciaMediaHoras;

    return GradeResponsiva(
      children: [
        CartaoIndicador(
          titulo: 'Antecedência média dos alertas',
          icone: Icons.timer_outlined,
          valor: antecedencia == null ? 'Sem alertas' : '${formatarNumero(antecedencia)} h',
          detalhe: 'Tempo entre o aviso e o pico previsto: tempo para avisar moradores e liberar bueiros.',
        ),
        CartaoIndicador(
          titulo: 'Moradores perto de córregos em alerta',
          icone: Icons.groups_outlined,
          valor: '${territorio.pessoasEmAreasComAlerta} de ${territorio.pessoasEmAreasMonitoradas}',
          detalhe: 'Estimativa ilustrativa de pessoas nas áreas monitoradas que podem ser avisadas antes.',
        ),
        CartaoIndicador(
          titulo: 'Relatos da comunidade',
          icone: Icons.campaign_outlined,
          valor: '$ocorrencias',
          detalhe: 'Ocorrências registradas de forma anônima neste aparelho.',
        ),
      ],
    );
  }
}

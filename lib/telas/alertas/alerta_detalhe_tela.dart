import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/aviso_decisao_humana.dart';
import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/chip_nivel.dart';
import '../../componentes/corpo_territorio.dart';
import '../../componentes/estados_tela.dart';
import '../../core/tema/cores.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/alerta.dart';
import '../../estado/preferencias_provider.dart';
import '../../logica/descricoes.dart';
import '../../rotas.dart';

/// Detalhe de UM alerta: evidências, confiança, limitações e a decisão humana.
/// Recebe o id pela rota nomeada (Rotas.alerta).
class AlertaDetalheTela extends StatelessWidget {
  const AlertaDetalheTela({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Rotas.argumento(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: CorpoTerritorio(
        construir: (context, territorio) {
          final alerta = territorio.alertaPorId(id);
          if (alerta == null) {
            return const [
              EstadoVazio(
                icone: Icons.history_toggle_off,
                titulo: 'Este alerta não está mais ativo',
                mensagem: 'Os dados foram atualizados e a previsão deixou de atingir o limiar.',
                rolavel: false,
              ),
            ];
          }
          return [
            _Cabecalho(alerta),
            const SecaoTitulo('Por que este alerta? (evidências)'),
            CartaoPadrao(child: ListaMarcadores(alerta.evidencias, icone: Icons.fact_check_outlined)),
            const SecaoTitulo('Nível de confiança'),
            CartaoPadrao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarraConfianca(confianca: alerta.confianca, rotulo: alerta.rotuloConfianca),
                  const SizedBox(height: Espaco.m),
                  Text(Descricoes.comoCalculamosConfianca(alerta.dominio)),
                ],
              ),
            ),
            const SecaoTitulo('Limitações (quando a previsão pode errar)'),
            CartaoPadrao(child: ListaMarcadores(alerta.limitacoes, icone: Icons.info_outline)),
            const SecaoTitulo('Sugestão para avaliação'),
            CartaoPadrao(child: Text(alerta.nivel.sugestao)),
            const SizedBox(height: Espaco.m),
            const AvisoDecisaoHumana(),
            const SizedBox(height: Espaco.m),
            _BotaoAvaliado(alerta.id),
            const SizedBox(height: Espaco.p),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Rotas.indicador, arguments: alerta.indicadorId),
              icon: const Icon(Icons.show_chart),
              label: const Text('Ver o indicador deste alerta'),
            ),
          ];
        },
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho(this.alerta);

  final Alerta alerta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final antecedencia = alerta.antecedenciaHoras;
    return CartaoPadrao(
      corFundo: CoresApp.doNivel(alerta.nivel).withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipNivel(alerta.nivel, grande: true),
          const SizedBox(height: Espaco.m),
          Semantics(header: true, child: Text(alerta.titulo, style: tema.textTheme.headlineSmall)),
          const SizedBox(height: Espaco.p),
          Text(alerta.resumo, style: tema.textTheme.bodyLarge),
          const SizedBox(height: Espaco.m),
          Wrap(
            spacing: Espaco.g,
            runSpacing: Espaco.xs,
            children: [
              Text('Gerado em ${formatarDataHora(alerta.geradoEm)}', style: tema.textTheme.bodySmall),
              Text('Painel: ${alerta.dominio.rotulo}', style: tema.textTheme.bodySmall),
              if (alerta.eventoPrevistoEm != null && antecedencia != null && antecedencia < 72)
                Text('Antecedência: ${formatarNumero(antecedencia)} h', style: tema.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// A pessoa registra que AVALIOU o alerta (a decisão é dela; o app só lembra).
class _BotaoAvaliado extends StatelessWidget {
  const _BotaoAvaliado(this.alertaId);

  final String alertaId;

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasProvider>();
    final avaliado = preferencias.foiAvaliado(alertaId);
    return FilledButton.tonalIcon(
      onPressed: () {
        preferencias.alternarAvaliado(alertaId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(avaliado ? 'Marcação de avaliado removida.' : 'Alerta marcado como avaliado por você.'),
        ));
      },
      icon: Icon(avaliado ? Icons.undo : Icons.how_to_reg_outlined),
      label: Text(avaliado ? 'Avaliado por mim (desfazer)' : 'Marcar como avaliado por mim'),
    );
  }
}

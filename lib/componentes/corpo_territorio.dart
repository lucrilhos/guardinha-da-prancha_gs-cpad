import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/tema/espacos.dart';
import '../estado/territorio_provider.dart';
import 'basicos.dart';
import 'estados_tela.dart';

/// Corpo padrão das telas que mostram dados do território.
/// Cuida sozinho dos estados: carregando, erro e "puxar para atualizar".
class CorpoTerritorio extends StatelessWidget {
  const CorpoTerritorio({super.key, required this.construir});

  /// Monta o conteúdo quando os dados estão prontos.
  final List<Widget> Function(BuildContext context, TerritorioProvider territorio) construir;

  @override
  Widget build(BuildContext context) {
    // troca suave entre carregando / erro / conteúdo: a pessoa percebe que o estado mudou
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: _corpo(context),
    );
  }

  Widget _corpo(BuildContext context) {
    final territorio = context.watch<TerritorioProvider>();

    if (!territorio.temDados) {
      if (territorio.status == StatusCarga.erro) {
        return EstadoErro(
          key: const ValueKey('erro'),
          mensagem: territorio.mensagemErro ?? 'Erro desconhecido.',
          aoTentarNovamente: territorio.carregar,
        );
      }
      return const EstadoCarregando(key: ValueKey('carregando'));
    }

    return RefreshIndicator(
      key: const ValueKey('conteudo'),
      onRefresh: territorio.carregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(Espaco.m, Espaco.m, Espaco.m, Espaco.xg * 2),
        children: [
          if (territorio.status == StatusCarga.carregando)
            const Padding(
              padding: EdgeInsets.only(bottom: Espaco.p),
              child: LinearProgressIndicator(semanticsLabel: 'Atualizando dados'),
            ),
          ConteudoCentral(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: construir(context, territorio),
            ),
          ),
        ],
      ),
    );
  }
}

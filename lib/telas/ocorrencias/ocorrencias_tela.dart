import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../componentes/estados_tela.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/ocorrencia.dart';
import '../../estado/ocorrencias_provider.dart';
import '../../rotas.dart';

/// Lista das ocorrências registradas pelo cidadão (salvas no aparelho).
class OcorrenciasTela extends StatelessWidget {
  const OcorrenciasTela({super.key});

  @override
  Widget build(BuildContext context) {
    final ocorrencias = context.watch<OcorrenciasProvider>().ocorrencias;

    return Scaffold(
      appBar: AppBar(title: const Text('Ocorrências')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Rotas.novaOcorrencia),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
        tooltip: 'Registrar nova ocorrência',
      ),
      body: ocorrencias.isEmpty
          ? EstadoVazio(
              icone: Icons.inbox_outlined,
              titulo: 'Nenhuma ocorrência registrada',
              mensagem: 'Viu um alagamento, um córrego subindo ou um bueiro entupido? '
                  'Registre de forma anônima: isso ajuda a confirmar (ou desmentir) os alertas.',
              acao: FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, Rotas.novaOcorrencia),
                icon: const Icon(Icons.add),
                label: const Text('Registrar ocorrência'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(Espaco.m, Espaco.m, Espaco.m, Espaco.xg * 3),
              children: [
                ConteudoCentral(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Relatos anônimos: guardamos só o tipo, a região e a descrição, apenas neste aparelho.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: Espaco.m),
                      for (final ocorrencia in ocorrencias)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Espaco.p),
                          child: _CartaoOcorrencia(ocorrencia),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartaoOcorrencia extends StatelessWidget {
  const _CartaoOcorrencia(this.ocorrencia);

  final Ocorrencia ocorrencia;

  Future<void> _confirmarRemocao(BuildContext context) async {
    final provider = context.read<OcorrenciasProvider>();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Apagar ocorrência?'),
        content: const Text('Ela será removida deste aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextoDialogo, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(contextoDialogo, true), child: const Text('Apagar')),
        ],
      ),
    );
    if (confirmou == true) await provider.remover(ocorrencia.id);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return CartaoPadrao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(ocorrencia.tipo.rotulo, style: tema.textTheme.titleMedium)),
              IconButton(
                tooltip: 'Apagar ocorrência',
                onPressed: () => _confirmarRemocao(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Text('${ocorrencia.regiao} · ${formatarDataHora(ocorrencia.criadaEm)}', style: tema.textTheme.bodySmall),
          const SizedBox(height: Espaco.p),
          Text(ocorrencia.descricao),
          const SizedBox(height: Espaco.p),
          Text('Gravidade percebida: ${ocorrencia.rotuloGravidade}', style: tema.textTheme.labelMedium),
        ],
      ),
    );
  }
}

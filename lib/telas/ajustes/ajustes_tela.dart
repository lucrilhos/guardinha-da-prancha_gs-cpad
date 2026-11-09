import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../core/tema/espacos.dart';
import '../../estado/ocorrencias_provider.dart';
import '../../estado/preferencias_provider.dart';
import '../../estado/territorio_provider.dart';
import '../../rotas.dart';

/// Aparência, acessibilidade, limiares, modo demonstração e privacidade.
class AjustesTela extends StatelessWidget {
  const AjustesTela({super.key});

  Future<void> _apagarDados(BuildContext context) async {
    final preferencias = context.read<PreferenciasProvider>();
    final ocorrencias = context.read<OcorrenciasProvider>();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Apagar meus dados?'),
        content: const Text('Isso apaga suas ocorrências, as marcações de alertas avaliados e o seu consentimento. '
            'O app volta para a tela inicial de consentimento.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextoDialogo, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(contextoDialogo, true), child: const Text('Apagar tudo')),
        ],
      ),
    );
    if (confirmou != true) return;
    ocorrencias.esvaziar();
    await preferencias.apagarDadosPessoais();
  }

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasProvider>();
    final territorio = context.read<TerritorioProvider>();
    final tema = Theme.of(context);

    // muda uma chave do modo demonstração e recarrega os dados
    Future<void> mudarERecarregar(Future<void> Function() mudanca) async {
      await mudanca();
      await territorio.carregar();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espaco.m, 0, Espaco.m, Espaco.xg),
        children: [
          ConteudoCentral(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SecaoTitulo('Aparência e acessibilidade'),
                CartaoPadrao(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Tema', style: tema.textTheme.labelLarge),
                      const SizedBox(height: Espaco.p),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Escuro'), icon: Icon(Icons.dark_mode)),
                          ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.phone_android)),
                        ],
                        selected: {preferencias.modoTema},
                        onSelectionChanged: (selecao) => preferencias.definirTema(selecao.first),
                      ),
                      const SizedBox(height: Espaco.p),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Alto contraste'),
                        subtitle: const Text('Preto no branco, bordas fortes'),
                        value: preferencias.altoContraste,
                        onChanged: preferencias.definirAltoContraste,
                      ),
                      Text('Tamanho do texto: ${(preferencias.escalaFonte * 100).round()}%',
                          style: tema.textTheme.labelLarge),
                      Slider(
                        value: preferencias.escalaFonte,
                        min: 1.0,
                        max: 1.6,
                        divisions: 6,
                        label: '${(preferencias.escalaFonte * 100).round()}%',
                        semanticFormatterCallback: (valor) => 'Tamanho do texto ${(valor * 100).round()} por cento',
                        onChanged: preferencias.definirEscalaFonte,
                      ),
                    ],
                  ),
                ),
                const SecaoTitulo('Alertas'),
                CartaoPadrao(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('Configurar limiares de alerta'),
                    subtitle: const Text('A partir de quanto o app deve avisar'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, Rotas.limiares),
                  ),
                ),
                const SecaoTitulo('Demonstração (testes e vídeo)'),
                CartaoPadrao(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Cenário de tempestade e estiagem'),
                        subtitle: const Text('Dados FICTÍCIOS para ver os alertas em ação'),
                        value: preferencias.modoDemonstracao,
                        onChanged: (v) => mudarERecarregar(() => preferencias.definirModoDemonstracao(v)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Simular sem conexão'),
                        subtitle: const Text('Ignora a internet e usa o cache do aparelho'),
                        value: preferencias.simularSemConexao,
                        onChanged: (v) => mudarERecarregar(() => preferencias.definirSimularSemConexao(v)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Simular falha total dos dados'),
                        subtitle: const Text('Mostra a tela de erro com "Tentar novamente"'),
                        value: preferencias.simularErro,
                        onChanged: (v) => mudarERecarregar(() => preferencias.definirSimularErro(v)),
                      ),
                    ],
                  ),
                ),
                const SecaoTitulo('Privacidade'),
                CartaoPadrao(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Sobre o app e privacidade'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, Rotas.sobre),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.delete_forever_outlined, color: tema.colorScheme.error),
                        title: Text('Apagar meus dados', style: TextStyle(color: tema.colorScheme.error)),
                        subtitle: const Text('Ocorrências, avaliações e consentimento'),
                        onTap: () => _apagarDados(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

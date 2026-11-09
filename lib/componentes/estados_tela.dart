import 'package:flutter/material.dart';

import '../core/tema/espacos.dart';

// Os três estados especiais de qualquer tela: carregando, erro e vazio.

class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key, this.mensagem = 'Carregando dados do território...'});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: mensagem,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: Espaco.m),
            Text(mensagem, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.mensagem, required this.aoTentarNovamente});

  final String mensagem;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return _Centralizado(
      children: [
        Icon(Icons.cloud_off_rounded, size: 56, color: cores.error),
        const SizedBox(height: Espaco.m),
        Text('Algo deu errado', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: Espaco.p),
        Text(mensagem, textAlign: TextAlign.center),
        const SizedBox(height: Espaco.g),
        FilledButton.icon(
          onPressed: aoTentarNovamente,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.acao,
    this.rolavel = true,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;

  /// Botão opcional (ex.: "Registrar ocorrência").
  final Widget? acao;

  /// false quando o estado já está dentro de uma lista que rola.
  final bool rolavel;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return _Centralizado(
      rolavel: rolavel,
      children: [
        Icon(icone, size: 56, color: cores.primary),
        const SizedBox(height: Espaco.m),
        Text(titulo, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: Espaco.p),
        Text(mensagem, textAlign: TextAlign.center),
        if (acao != null) ...[const SizedBox(height: Espaco.g), acao!],
      ],
    );
  }
}

/// Coluna centralizada que rola se a fonte estiver muito grande.
class _Centralizado extends StatelessWidget {
  const _Centralizado({required this.children, this.rolavel = true});

  final List<Widget> children;
  final bool rolavel;

  @override
  Widget build(BuildContext context) {
    final conteudo = Padding(
      padding: const EdgeInsets.all(Espaco.g),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
    return Center(child: rolavel ? SingleChildScrollView(child: conteudo) : conteudo);
  }
}

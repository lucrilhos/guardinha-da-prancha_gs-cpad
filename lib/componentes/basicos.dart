import 'package:flutter/material.dart';

import '../core/tema/espacos.dart';
import '../core/utils/formatadores.dart';

// Pequenos componentes reutilizados em várias telas.

/// Logo do app (arquivo em assets/marca/logo.png — basta trocar a imagem).
class LogoApp extends StatelessWidget {
  const LogoApp({super.key, this.tamanho = 40});

  static const caminho = 'assets/marca/logo.png';
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tamanho * 0.22),
      child: Image.asset(
        caminho,
        width: tamanho,
        height: tamanho,
        semanticLabel: 'Logo do Guardinha da Prancha',
      ),
    );
  }
}

/// Título de seção dentro de uma tela (ex.: "Painéis do território").
class SecaoTitulo extends StatelessWidget {
  const SecaoTitulo(this.texto, {super.key, this.acao});

  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Espaco.g, bottom: Espaco.p),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(texto, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (acao != null) acao!,
        ],
      ),
    );
  }
}

/// Barra de 0 a 100% com o nível de confiança de um alerta.
class BarraConfianca extends StatelessWidget {
  const BarraConfianca({super.key, required this.confianca, required this.rotulo});

  final double confianca;

  /// "Alta", "Média" ou "Baixa".
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Nível de confiança: $rotulo, ${formatarPorcentagem(confianca)}.',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$rotulo (${formatarPorcentagem(confianca)})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: Espaco.p),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // a barra "enche" até o valor: reforça visualmente quanto o alerta é confiável
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: confianca),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, valor, _) => LinearProgressIndicator(
                value: valor,
                minHeight: 10,
                color: cores.primary,
                backgroundColor: cores.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista com marcadores (evidências, limitações...).
class ListaMarcadores extends StatelessWidget {
  const ListaMarcadores(this.itens, {super.key, this.icone = Icons.circle});

  final List<String> itens;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in itens)
          Padding(
            padding: const EdgeInsets.only(bottom: Espaco.p),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: ExcludeSemantics(
                    child: Icon(icone, size: icone == Icons.circle ? 8 : 18,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(width: Espaco.p),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Centraliza o conteúdo e limita a largura em tablets/paisagem (responsividade).
class ConteudoCentral extends StatelessWidget {
  const ConteudoCentral({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Espaco.larguraMaxima),
        child: child,
      ),
    );
  }
}

/// Grade responsiva: 1 coluna no celular, 2 em telas médias, 3 em telas largas.
class GradeResponsiva extends StatelessWidget {
  const GradeResponsiva({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) {
        final colunas = restricoes.maxWidth >= 720
            ? 3
            : restricoes.maxWidth >= 480
                ? 2
                : 1;
        final largura = (restricoes.maxWidth - Espaco.m * (colunas - 1)) / colunas;
        return Wrap(
          spacing: Espaco.m,
          runSpacing: Espaco.m,
          children: [for (final c in children) SizedBox(width: largura, child: c)],
        );
      },
    );
  }
}

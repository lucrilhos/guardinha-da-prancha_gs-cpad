import 'package:flutter/material.dart';

import '../core/tema/espacos.dart';

/// Cartão base do app: mesmo raio, borda e espaçamento em todas as telas.
/// Se tiver [aoTocar], vira um botão (com efeito de toque e anúncio para leitor de tela).
class CartaoPadrao extends StatelessWidget {
  const CartaoPadrao({
    super.key,
    required this.child,
    this.aoTocar,
    this.rotuloAcessivel,
    this.corFundo,
    this.padding = const EdgeInsets.all(Espaco.m),
  });

  final Widget child;
  final VoidCallback? aoTocar;

  /// Frase lida pelo leitor de tela no lugar do conteúdo (opcional).
  final String? rotuloAcessivel;
  final Color? corFundo;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final cartao = Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: corFundo ?? cores.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Espaco.raio),
        side: BorderSide(color: cores.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (rotuloAcessivel == null) return cartao;
    return Semantics(
      label: rotuloAcessivel,
      button: aoTocar != null,
      excludeSemantics: true,
      onTap: aoTocar,
      child: cartao,
    );
  }
}

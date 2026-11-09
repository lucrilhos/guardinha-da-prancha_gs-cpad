import 'package:flutter/material.dart';

import '../core/tema/espacos.dart';
import '../dados/modelos/nivel_alerta.dart';
import 'cartao_padrao.dart';
import 'chip_nivel.dart';

/// Cartão de um número importante (ex.: "Chuva prevista 24 h — 67,0 mm").
class CartaoIndicador extends StatelessWidget {
  const CartaoIndicador({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    this.detalhe,
    this.nivel,
    this.aoTocar,
  });

  final String titulo;

  /// Já formatado, com unidade (ex.: "67,0 mm").
  final String valor;
  final IconData icone;

  /// Linha menor embaixo do valor (ex.: tendência).
  final String? detalhe;

  /// Se informado, mostra a etiqueta de nível.
  final NivelAlerta? nivel;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final rotulo = [
      '$titulo: $valor.',
      if (detalhe != null) '$detalhe.',
      if (nivel != null) 'Nível ${nivel!.rotulo}.',
      if (aoTocar != null) 'Toque para ver detalhes.',
    ].join(' ');

    return CartaoPadrao(
      aoTocar: aoTocar,
      rotuloAcessivel: rotulo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: tema.colorScheme.primary),
              const SizedBox(width: Espaco.p),
              Expanded(child: Text(titulo, style: tema.textTheme.labelLarge)),
              if (aoTocar != null) Icon(Icons.chevron_right, color: tema.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: Espaco.p),
          Text(
            valor,
            style: tema.textTheme.headlineSmall?.copyWith(
              color: tema.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (detalhe != null) ...[
            const SizedBox(height: Espaco.xs),
            Text(detalhe!, style: tema.textTheme.bodySmall),
          ],
          if (nivel != null) ...[
            const SizedBox(height: Espaco.p),
            ChipNivel(nivel!),
          ],
        ],
      ),
    );
  }
}

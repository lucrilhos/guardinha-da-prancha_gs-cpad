import 'package:flutter/material.dart';

import '../core/tema/espacos.dart';

/// Aviso fixo: os alertas APOIAM a decisão, não a substituem.
class AvisoDecisaoHumana extends StatelessWidget {
  const AvisoDecisaoHumana({super.key, this.compacto = false});

  /// Versão de uma linha para o topo das listas.
  final bool compacto;

  static const textoCurto = 'Os alertas apoiam, mas não substituem, a decisão humana.';
  static const textoCompleto = 'Este alerta é uma estimativa feita a partir de dados e pode errar. '
      'Ele serve para apoiar a avaliação da Defesa Civil e dos moradores, nunca para decidir sozinho. '
      'Em caso de risco imediato, ligue 199 (Defesa Civil) ou 193 (Bombeiros).';

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: compacto ? textoCurto : textoCompleto,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(Espaco.m),
        decoration: BoxDecoration(
          color: cores.secondaryContainer,
          borderRadius: BorderRadius.circular(Espaco.raio),
          border: Border.all(color: cores.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.groups_rounded, color: cores.onSecondaryContainer),
            const SizedBox(width: Espaco.p + Espaco.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A decisão final é humana',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: cores.onSecondaryContainer, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Espaco.xs),
                  Text(
                    compacto ? textoCurto : textoCompleto,
                    style: TextStyle(color: cores.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

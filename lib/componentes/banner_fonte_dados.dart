import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/tema/espacos.dart';
import '../core/utils/formatadores.dart';
import '../dados/fontes/clima_api.dart';
import '../estado/territorio_provider.dart';

/// Faixa que diz DE ONDE vêm os dados agora: ao vivo, cache, exemplo ou demonstração.
/// Transparência: a pessoa sempre sabe se está vendo dado velho ou fictício.
class BannerFonteDados extends StatelessWidget {
  const BannerFonteDados({super.key});

  @override
  Widget build(BuildContext context) {
    final territorio = context.watch<TerritorioProvider>();
    final cores = Theme.of(context).colorScheme;
    final origem = territorio.origemClima;
    if (origem == null) return const SizedBox.shrink();

    final avisos = <(IconData, String)>[
      if (origem == OrigemDados.api)
        (Icons.wifi_rounded, 'Clima ao vivo (Open-Meteo), atualizado às ${formatarHora(territorio.agora)}.'),
      if (origem == OrigemDados.cache)
        (
          Icons.wifi_off_rounded,
          'Sem conexão: mostrando a previsão salva ${formatarIdade(territorio.agora.difference(territorio.climaObtidoEm!))}.'
        ),
      if (origem == OrigemDados.exemplo)
        (Icons.wifi_off_rounded, 'Sem conexão e sem dados salvos: mostrando DADOS DE EXEMPLO.'),
      if (territorio.cenarioDemonstracao)
        (Icons.science_outlined, 'MODO DEMONSTRAÇÃO: tempestade e estiagem fictícias.'),
    ];
    final destaque = origem != OrigemDados.api || territorio.cenarioDemonstracao;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: Espaco.m, vertical: Espaco.p),
        decoration: BoxDecoration(
          color: destaque ? cores.tertiaryContainer : cores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Espaco.raioPequeno),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (icone, texto) in avisos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Espaco.xs / 2),
                child: Row(
                  children: [
                    Icon(icone, size: 18, color: destaque ? cores.onTertiaryContainer : cores.onSurfaceVariant),
                    const SizedBox(width: Espaco.p),
                    Expanded(
                      child: Text(
                        texto,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: destaque ? cores.onTertiaryContainer : cores.onSurfaceVariant,
                            ),
                      ),
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

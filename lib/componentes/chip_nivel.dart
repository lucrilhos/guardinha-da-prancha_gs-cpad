import 'package:flutter/material.dart';

import '../core/tema/cores.dart';
import '../core/tema/espacos.dart';
import '../dados/modelos/nivel_alerta.dart';

/// Etiqueta colorida com o nível (ícone + texto: a cor nunca é a única informação).
class ChipNivel extends StatelessWidget {
  const ChipNivel(this.nivel, {super.key, this.grande = false});

  final NivelAlerta nivel;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final corTexto = CoresApp.textoSobre(nivel);
    final estilo = (grande ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.labelMedium)
        ?.copyWith(color: corTexto, fontWeight: FontWeight.bold);
    return Semantics(
      label: 'Nível ${nivel.rotulo}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: grande ? Espaco.m : Espaco.p, vertical: Espaco.xs),
        decoration: BoxDecoration(
          color: CoresApp.doNivel(nivel),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CoresApp.iconeDo(nivel), size: grande ? 20 : 16, color: corTexto),
            const SizedBox(width: Espaco.xs),
            Text(nivel.rotulo, style: estilo),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../dados/modelos/nivel_alerta.dart';

/// Paleta do Guardinha da Prancha. Nenhuma tela escreve cor "na mão": todas vêm daqui ou do tema.
class CoresApp {
  const CoresApp._();

  // marca
  static const petroleo = Color(0xFF0E5E6F);
  static const petroleoClaro = Color(0xFF7CC4D2);
  static const ambar = Color(0xFFF2A541);
  static const textoEscuro = Color(0xFF12262B);

  // fundos
  static const fundoClaro = Color(0xFFF5F7F7);
  static const fundoEscuro = Color(0xFF0E1A1D);
  static const superficieEscura = Color(0xFF172629);

  // níveis de alerta (contraste conferido com o texto indicado em [textoSobre])
  static const normal = Color(0xFF2E7D32);
  static const atencao = Color(0xFFF2C94C);
  static const alerta = Color(0xFFE8833A);
  static const critico = Color(0xFFC62828);

  static Color doNivel(NivelAlerta nivel) => switch (nivel) {
        NivelAlerta.normal => normal,
        NivelAlerta.atencao => atencao,
        NivelAlerta.alerta => alerta,
        NivelAlerta.critico => critico,
      };

  /// Texto escuro sobre amarelo/laranja, branco sobre verde/vermelho (contraste ≥ 4,5:1).
  static Color textoSobre(NivelAlerta nivel) => switch (nivel) {
        NivelAlerta.atencao || NivelAlerta.alerta => textoEscuro,
        NivelAlerta.normal || NivelAlerta.critico => Colors.white,
      };

  static IconData iconeDo(NivelAlerta nivel) => switch (nivel) {
        NivelAlerta.normal => Icons.check_circle_outline,
        NivelAlerta.atencao => Icons.visibility_outlined,
        NivelAlerta.alerta => Icons.warning_amber_rounded,
        NivelAlerta.critico => Icons.crisis_alert,
      };
}

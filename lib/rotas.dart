import 'package:flutter/material.dart';

import 'telas/alertas/alerta_detalhe_tela.dart';
import 'telas/indicador/indicador_detalhe_tela.dart';
import 'telas/limiares/limiares_tela.dart';
import 'telas/ocorrencias/ocorrencia_form_tela.dart';
import 'telas/paineis/painel_clima_tela.dart';
import 'telas/paineis/painel_corregos_tela.dart';
import 'telas/paineis/painel_reservatorios_tela.dart';
import 'telas/shell/portao_inicial.dart';
import 'telas/sobre/sobre_tela.dart';

/// Todas as rotas NOMEADAS do app num lugar só.
/// Fluxo principal: Início -> Painel -> Detalhe do indicador -> Detalhe do alerta.
class Rotas {
  const Rotas._();

  static const inicio = '/';
  static const painelClima = '/painel/clima';
  static const painelCorregos = '/painel/corregos';
  static const painelReservatorios = '/painel/reservatorios';

  /// Parâmetro: id do indicador (String).
  static const indicador = '/indicador';

  /// Parâmetro: id do alerta (String).
  static const alerta = '/alerta';

  static const novaOcorrencia = '/ocorrencias/nova';
  static const limiares = '/ajustes/limiares';
  static const sobre = '/sobre';

  static Map<String, WidgetBuilder> get mapa => {
        inicio: (_) => const PortaoInicial(),
        painelClima: (_) => const PainelClimaTela(),
        painelCorregos: (_) => const PainelCorregosTela(),
        painelReservatorios: (_) => const PainelReservatoriosTela(),
        indicador: (_) => const IndicadorDetalheTela(),
        alerta: (_) => const AlertaDetalheTela(),
        novaOcorrencia: (_) => const OcorrenciaFormTela(),
        limiares: (_) => const LimiaresTela(),
        sobre: (_) => const SobreTela(),
      };

  /// Lê o parâmetro (id) que veio no Navigator.pushNamed(..., arguments: id).
  static String argumento(BuildContext context) => ModalRoute.of(context)?.settings.arguments as String? ?? '';
}

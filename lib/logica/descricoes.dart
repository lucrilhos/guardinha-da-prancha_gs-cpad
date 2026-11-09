import 'dart:math';

import '../core/utils/formatadores.dart';
import '../dados/modelos/indicador.dart';
import '../dados/modelos/limiares.dart';
import '../dados/modelos/nivel_alerta.dart';
import 'estatistica.dart';

/// Textos e números derivados de um indicador, usados por várias telas.
class Descricoes {
  const Descricoes._();

  /// "Últimas 3 h: +0,35 m (subindo)" ou "Tendência (30 dias): -0,12 p.p./dia".
  static String tendencia(Indicador indicador) {
    final h = indicador.historico;
    if (h.length < 4) return 'Poucos dados para calcular a tendência.';

    if (indicador.dominio == Dominio.reservatorios) {
      final n = min(30, h.length);
      final reta = regressaoLinear(h.sublist(h.length - n).map((p) => p.valor).toList());
      final sinal = reta.inclinacao >= 0 ? '+' : '';
      return 'Tendência ($n dias): $sinal${formatarNumero(reta.inclinacao, casas: 2)} p.p./dia';
    }

    final variacao = h.last.valor - h[h.length - 4].valor;
    final sentido = variacao.abs() < 0.02
        ? 'estável'
        : variacao > 0
            ? 'subindo'
            : 'descendo';
    final sinal = variacao >= 0 ? '+' : '';
    return 'Últimas 3 h: $sinal${formatarNumero(variacao, casas: indicador.casasDecimais)} ${indicador.unidade} ($sentido)';
  }

  /// Os limites que fazem sentido desenhar no gráfico de cada indicador.
  static List<LinhaLimite> limitesDoGrafico(Indicador indicador, Limiares limiares) {
    final limiar = switch (indicador.dominio) {
      Dominio.corregos => limiares.nivelCorrego,
      Dominio.reservatorios => limiares.reservatorio,
      Dominio.clima => null, // o limite de chuva é sobre a SOMA de 24 h, não sobre cada hora
    };
    if (limiar == null) return const [];
    return [
      LinhaLimite(limiar.atencao, NivelAlerta.atencao),
      LinhaLimite(limiar.alerta, NivelAlerta.alerta),
      LinhaLimite(limiar.critico, NivelAlerta.critico),
    ];
  }

  /// Nível do valor previsto mais grave do indicador (usado nos cartões dos painéis).
  static NivelAlerta nivelPrevisto(Indicador indicador, Limiares limiares) {
    final limiar = switch (indicador.dominio) {
      Dominio.corregos => limiares.nivelCorrego,
      Dominio.reservatorios => limiares.reservatorio,
      Dominio.clima => null,
    };
    if (limiar == null || indicador.historico.isEmpty) return NivelAlerta.normal;
    final valores = [indicador.historico.last.valor, ...indicador.previsao.map((p) => p.valor)];
    final pior = limiar.inverso ? valores.reduce(min) : valores.reduce(max);
    return limiar.classificar(pior);
  }

  /// Como a confiança é calculada em cada painel (mostrado no detalhe do alerta).
  static String comoCalculamosConfianca(Dominio dominio) => switch (dominio) {
        Dominio.clima => 'Parte da probabilidade de chuva informada pelo modelo meteorológico e diminui quando '
            'a chuva prevista está a mais de 12 horas ou quando os dados não são ao vivo.',
        Dominio.corregos => 'Começa em "média" porque as leituras do córrego são simuladas, e sobe um pouco '
            'quando o córrego já está subindo. Também diminui quando a previsão de chuva não é ao vivo.',
        Dominio.reservatorios => 'Depende de quão bem uma reta descreve os últimos 30 dias de volume (R²) e '
            'diminui quando os dados públicos têm mais de 15 dias.',
      };
}

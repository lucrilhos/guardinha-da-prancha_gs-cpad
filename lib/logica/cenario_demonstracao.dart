import 'dart:math';

import '../dados/fontes/clima_api.dart';
import '../dados/fontes/reservatorios_local.dart';
import '../dados/modelos/indicador.dart';

/// MODO DEMONSTRAÇÃO (liga em Ajustes): altera os dados para mostrar alertas em ação,
/// por exemplo no vídeo. A tela avisa o tempo todo que o cenário é fictício.
class CenarioDemonstracao {
  const CenarioDemonstracao._();

  /// Pico de chuva da tempestade fictícia, em mm/h.
  static const picoTempestade = 22.0;

  /// Tempestade: já chove 6 mm/h nas últimas 3 horas e vem um temporal com pico daqui a 5 horas.
  static ClimaDados tempestade(ClimaDados dados, DateTime agora) {
    final horaAtual = DateTime(agora.year, agora.month, agora.day, agora.hour);

    double chuvaExtra(DateTime momento) {
      final horas = momento.difference(horaAtual).inMinutes / 60;
      if (horas > 0 && horas <= 9) return picoTempestade * exp(-pow(horas - 5, 2) / 3);
      if (horas > -3 && horas <= 0) return 6;
      return 0;
    }

    return dados.copiarCom(
      chuva: [for (final p in dados.chuva) PontoSerie(p.momento, p.valor + chuvaExtra(p.momento))],
      probabilidade: [
        for (final p in dados.probabilidade)
          PontoSerie(p.momento, chuvaExtra(p.momento) > 1 ? max(p.valor, 85.0) : p.valor),
      ],
    );
  }

  /// Estiagem no Sistema Integrado: tira 0,6 ponto percentual por dia nos últimos 30 dias.
  static List<Indicador> estiagem(List<Indicador> reservatorios) => [
        for (final r in reservatorios)
          if (r.id != 'reservatorio-integrado') r else _comEstiagem(r),
      ];

  static Indicador _comEstiagem(Indicador r) {
    final n = r.historico.length;
    final historico = [
      for (var i = 0; i < n; i++)
        PontoSerie(
          r.historico[i].momento,
          // só os últimos 30 dias perdem volume, cada dia um pouco mais
          (r.historico[i].valor - max(0, i - (n - 31)) * 0.6).clamp(0, 100).toDouble(),
        ),
    ];
    return r.copiarCom(
      historico: historico,
      previsao: ReservatoriosLocal.projetar(historico),
      fonte: '${r.fonte} – ALTERADO pelo modo demonstração',
    );
  }
}

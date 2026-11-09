import 'dart:math';

import '../modelos/indicador.dart';

/// Um córrego monitorado. A população é uma ESTIMATIVA ILUSTRATIVA do grupo
/// (não vem de censo), usada só no indicador de benefício social.
class Corrego {
  const Corrego({
    required this.id,
    required this.nome,
    required this.local,
    required this.nivelBase,
    required this.fatorResposta,
    required this.populacaoEstimada,
  });

  final String id;
  final String nome;
  final String local;

  /// Nível em tempo seco, em metros.
  final double nivelBase;

  /// Quanto o córrego "reage" à chuva (1 = normal; maior = enche mais rápido).
  final double fatorResposta;
  final int populacaoEstimada;
}

/// Gera leituras SINTÉTICAS de nível dos córregos a partir da chuva.
/// Ideia: o córrego sobe algumas horas DEPOIS da chuva, como na vida real.
///   nível(hora) = nível base + soma(peso × chuva de 1 a 6 horas atrás) + pequeno ruído
class CorregosSimulados {
  const CorregosSimulados();

  /// Altura da margem: acima disso o córrego transborda.
  static const margem = 4.0;

  static const corregos = [
    Corrego(
      id: 'corrego-meninos',
      nome: 'Ribeirão dos Meninos',
      local: 'Rudge Ramos – São Bernardo do Campo',
      nivelBase: 0.9,
      fatorResposta: 1.0,
      populacaoEstimada: 12000,
    ),
    Corrego(
      id: 'corrego-couros',
      nome: 'Ribeirão dos Couros',
      local: 'Divisa São Bernardo do Campo / Diadema',
      nivelBase: 0.7,
      fatorResposta: 1.15,
      populacaoEstimada: 9000,
    ),
    Corrego(
      id: 'corrego-tamanduatei',
      nome: 'Rio Tamanduateí',
      local: 'Centro – Santo André',
      nivelBase: 1.2,
      fatorResposta: 0.85,
      populacaoEstimada: 15000,
    ),
  ];

  /// Peso (metros por mm) da chuva de 1, 2, ... 6 horas atrás.
  static const _pesos = [0.05, 0.08, 0.07, 0.05, 0.03, 0.02];

  static Corrego? porId(String id) {
    for (final c in corregos) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// [chuvaHoraria] deve ter as horas passadas E as previstas (a previsão do nível usa a chuva prevista).
  List<Indicador> gerar(List<PontoSerie> chuvaHoraria, DateTime agora) {
    final chuvaPorHora = {for (final p in chuvaHoraria) _chaveHora(p.momento): p.valor};
    final horaAtual = DateTime(agora.year, agora.month, agora.day, agora.hour);
    return [for (final c in corregos) _gerarCorrego(c, chuvaPorHora, horaAtual)];
  }

  Indicador _gerarCorrego(Corrego c, Map<int, double> chuva, DateTime horaAtual) {
    double nivelEm(DateTime hora, {required bool comRuido}) {
      var nivel = c.nivelBase;
      for (var k = 1; k <= _pesos.length; k++) {
        final chuvaKHorasAntes = chuva[_chaveHora(hora.subtract(Duration(hours: k)))] ?? 0;
        nivel += _pesos[k - 1] * c.fatorResposta * chuvaKHorasAntes;
      }
      if (comRuido) nivel += _ruido(c.id, hora);
      return nivel.clamp(0.2, 4.6).toDouble();
    }

    final historico = [
      for (var h = 47; h >= 0; h--)
        PontoSerie(horaAtual.subtract(Duration(hours: h)),
            nivelEm(horaAtual.subtract(Duration(hours: h)), comRuido: true)),
    ];
    final previsao = [
      for (var h = 1; h <= 6; h++)
        PontoSerie(horaAtual.add(Duration(hours: h)), nivelEm(horaAtual.add(Duration(hours: h)), comRuido: false)),
    ];

    return Indicador(
      id: c.id,
      dominio: Dominio.corregos,
      titulo: c.nome,
      local: c.local,
      unidade: 'm',
      historico: historico,
      previsao: previsao,
      fonte: 'Sensor SIMULADO pelo app a partir da chuva (Open-Meteo)',
      comoCalculamos: 'Não há sensor real instalado: o nível é gerado por um modelo simples em que o córrego '
          'sobe de 1 a 6 horas depois da chuva. A previsão das próximas 6 horas usa a chuva prevista.',
      sintetico: true,
      casasDecimais: 2,
    );
  }

  static int _chaveHora(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour).millisecondsSinceEpoch ~/ Duration.millisecondsPerHour;

  /// Ruído pequeno (±5 cm) e sempre igual para a mesma hora: o gráfico não "pula" a cada atualização.
  static double _ruido(String id, DateTime hora) {
    final sementeId = id.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    return (Random(sementeId ^ _chaveHora(hora)).nextDouble() - 0.5) * 0.1;
  }
}

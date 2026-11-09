import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/utils/formatadores.dart';
import '../../logica/estatistica.dart';
import '../modelos/indicador.dart';

/// Volume dos mananciais (dados públicos da Sabesp), empacotados no app em assets/dados.
/// Por estar no próprio app, este painel funciona 100% offline.
class ReservatoriosLocal {
  const ReservatoriosLocal();

  static const caminho = 'assets/dados/reservatorios.json';

  /// Dias usados para ajustar a reta e dias projetados para frente.
  static const janelaDias = 30;
  static const diasProjetados = 30;

  Future<List<Indicador>> carregar() async {
    final texto = await rootBundle.loadString(caminho);
    return converter(jsonDecode(texto) as Map<String, dynamic>);
  }

  /// Separado do carregar() para poder ser testado sem Flutter.
  static List<Indicador> converter(Map<String, dynamic> json) {
    final registros = (json['registros'] as List).cast<Map<String, dynamic>>();
    final atualizadoAte = DateTime.parse(json['atualizado_ate'] as String);

    List<PontoSerie> serie(String chave) => [
          for (final r in registros) PontoSerie(DateTime.parse(r['data'] as String), (r[chave] as num).toDouble()),
        ];

    Indicador indicador(String id, String titulo, String local, List<PontoSerie> historico) => Indicador(
          id: id,
          dominio: Dominio.reservatorios,
          titulo: titulo,
          local: local,
          unidade: '%',
          historico: historico,
          previsao: projetar(historico),
          fonte: 'Sabesp – dados públicos dos mananciais (até ${formatarData(atualizadoAte)})',
          comoCalculamos: 'Porcentagem do volume útil. A previsão é uma reta ajustada aos últimos $janelaDias dias '
              'e prolongada por mais $diasProjetados dias (projeção linear).',
        );

    return [
      indicador('reservatorio-rio-grande', 'Sistema Rio Grande (Billings)', 'Abastece boa parte do ABC',
          serie('rio_grande_pct')),
      indicador('reservatorio-integrado', 'Sistema Integrado Metropolitano', 'Todos os mananciais da Grande SP',
          serie('integrado_pct')),
    ];
  }

  /// Projeção linear: reta dos últimos [janelaDias] dias prolongada por [diasProjetados] dias.
  static List<PontoSerie> projetar(List<PontoSerie> historico) {
    if (historico.length < janelaDias) return const [];
    final ultimos = historico.sublist(historico.length - janelaDias).map((p) => p.valor).toList();
    final reta = regressaoLinear(ultimos);
    final ultimaData = historico.last.momento;
    return [
      for (var d = 1; d <= diasProjetados; d++)
        PontoSerie(ultimaData.add(Duration(days: d)),
            reta.valorEm((janelaDias - 1 + d).toDouble()).clamp(0, 100).toDouble()),
    ];
  }
}

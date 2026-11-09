import 'package:http/http.dart' as http;

import '../modelos/indicador.dart';

/// De onde vieram os dados de clima que estão na tela.
enum OrigemDados {
  api('Ao vivo (API Open-Meteo)'),
  cache('Cache salvo no aparelho'),
  exemplo('Dados de exemplo do app');

  const OrigemDados(this.rotulo);

  final String rotulo;
}

class ClimaIndisponivelException implements Exception {
  const ClimaIndisponivelException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Chuva, probabilidade de chuva e temperatura hora a hora (passado + previsão).
class ClimaDados {
  const ClimaDados({
    required this.chuva,
    required this.probabilidade,
    required this.temperatura,
    required this.origem,
    required this.obtidoEm,
  });

  final List<PontoSerie> chuva;
  final List<PontoSerie> probabilidade;
  final List<PontoSerie> temperatura;
  final OrigemDados origem;

  /// Quando os dados foram baixados da API (para saber se estão velhos).
  final DateTime obtidoEm;

  /// Lê o JSON no formato da Open-Meteo.
  /// [deslocamento] serve só para os dados de exemplo: "traz" o arquivo para a data de hoje.
  factory ClimaDados.deOpenMeteo(
    Map<String, dynamic> json, {
    required OrigemDados origem,
    required DateTime obtidoEm,
    Duration deslocamento = Duration.zero,
  }) {
    final horario = json['hourly'] as Map<String, dynamic>;
    final tempos = (horario['time'] as List).cast<String>();

    List<PontoSerie> serie(String chave) {
      final valores = horario[chave] as List? ?? const [];
      final pontos = <PontoSerie>[];
      for (var i = 0; i < tempos.length && i < valores.length; i++) {
        final valor = valores[i];
        if (valor == null) continue; // a API às vezes manda horas sem valor
        pontos.add(PontoSerie(DateTime.parse(tempos[i]).add(deslocamento), (valor as num).toDouble()));
      }
      return pontos;
    }

    return ClimaDados(
      chuva: serie('precipitation'),
      probabilidade: serie('precipitation_probability'),
      temperatura: serie('temperature_2m'),
      origem: origem,
      obtidoEm: obtidoEm,
    );
  }

  ClimaDados copiarCom({List<PontoSerie>? chuva, List<PontoSerie>? probabilidade}) => ClimaDados(
        chuva: chuva ?? this.chuva,
        probabilidade: probabilidade ?? this.probabilidade,
        temperatura: temperatura,
        origem: origem,
        obtidoEm: obtidoEm,
      );

  /// Separa a série em "já aconteceu" (histórico) e "vai acontecer" (previsão).
  static (List<PontoSerie>, List<PontoSerie>) dividir(List<PontoSerie> serie, DateTime agora) {
    final historico = serie.where((p) => !p.momento.isAfter(agora)).toList();
    final previsao = serie.where((p) => p.momento.isAfter(agora)).toList();
    return (historico, previsao);
  }

  /// Os indicadores do painel de clima.
  List<Indicador> paraIndicadores(DateTime agora) {
    final (chuvaHist, chuvaPrev) = dividir(chuva, agora);
    final (tempHist, tempPrev) = dividir(temperatura, agora);
    final (probHist, probPrev) = dividir(probabilidade, agora);
    const fonte = 'Open-Meteo (dados abertos de modelos meteorológicos)';
    return [
      Indicador(
        id: 'clima-chuva',
        dominio: Dominio.clima,
        titulo: 'Chuva por hora',
        local: ClimaApi.nomeLocal,
        unidade: 'mm',
        historico: chuvaHist,
        previsao: chuvaPrev,
        fonte: fonte,
        comoCalculamos: 'Milímetros de chuva em cada hora. As horas passadas são estimativas do modelo; '
            'as futuras são a previsão. O alerta soma a chuva prevista das próximas 24 horas.',
      ),
      Indicador(
        id: 'clima-temperatura',
        dominio: Dominio.clima,
        titulo: 'Temperatura',
        local: ClimaApi.nomeLocal,
        unidade: '°C',
        historico: tempHist,
        previsao: tempPrev,
        fonte: fonte,
        comoCalculamos: 'Temperatura do ar a 2 metros do chão, hora a hora.',
      ),
      Indicador(
        id: 'clima-probabilidade',
        dominio: Dominio.clima,
        titulo: 'Probabilidade de chuva',
        local: ClimaApi.nomeLocal,
        unidade: '%',
        historico: probHist,
        previsao: probPrev,
        fonte: fonte,
        comoCalculamos: 'Chance de chover em cada hora, segundo o modelo. É usada para calcular a confiança '
            'do alerta de chuva.',
        casasDecimais: 0,
      ),
    ];
  }
}

/// Consome a API pública Open-Meteo (gratuita, sem chave de API).
class ClimaApi {
  ClimaApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  static const latitude = -23.69;
  static const longitude = -46.56;
  static const nomeLocal = 'São Bernardo do Campo (centro)';

  /// Devolve o JSON como texto, do jeito que veio, para poder guardar no cache.
  Future<String> buscar() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'hourly': 'precipitation,precipitation_probability,temperature_2m',
      'past_days': '2',
      'forecast_days': '2',
      'timezone': 'America/Sao_Paulo',
    });
    final resposta = await _cliente.get(uri).timeout(const Duration(seconds: 10));
    if (resposta.statusCode != 200) {
      throw ClimaIndisponivelException('A API de clima respondeu com o código ${resposta.statusCode}.');
    }
    return resposta.body;
  }
}

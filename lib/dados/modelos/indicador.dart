/// Um ponto de uma série no tempo (ex.: 12,5 mm de chuva às 15:00).
class PontoSerie {
  const PontoSerie(this.momento, this.valor);

  final DateTime momento;
  final double valor;
}

/// Os três painéis do app.
enum Dominio {
  clima('Clima', 'Chuva e temperatura'),
  corregos('Córregos', 'Nível dos córregos'),
  reservatorios('Reservatórios', 'Volume dos mananciais');

  const Dominio(this.rotulo, this.descricao);

  final String rotulo;
  final String descricao;
}

/// Um indicador do território com histórico e (quando existe) previsão.
class Indicador {
  const Indicador({
    required this.id,
    required this.dominio,
    required this.titulo,
    required this.local,
    required this.unidade,
    required this.historico,
    this.previsao = const [],
    required this.fonte,
    required this.comoCalculamos,
    this.sintetico = false,
    this.casasDecimais = 1,
  });

  final String id;
  final Dominio dominio;
  final String titulo;
  final String local;
  final String unidade;

  /// Valores já medidos, do mais antigo para o mais novo.
  final List<PontoSerie> historico;

  /// Valores previstos, do mais próximo para o mais distante.
  final List<PontoSerie> previsao;

  /// De onde o dado vem (aparece na tela, por transparência).
  final String fonte;

  /// Explicação simples de como o número é obtido.
  final String comoCalculamos;

  /// true = dado gerado pelo app (não é medição real).
  final bool sintetico;
  final int casasDecimais;

  double? get valorAtual => historico.isEmpty ? null : historico.last.valor;
  DateTime? get atualizadoEm => historico.isEmpty ? null : historico.last.momento;

  /// Cópia com outro histórico/previsão (usada pelo modo demonstração).
  Indicador copiarCom({List<PontoSerie>? historico, List<PontoSerie>? previsao, String? fonte}) => Indicador(
        id: id,
        dominio: dominio,
        titulo: titulo,
        local: local,
        unidade: unidade,
        historico: historico ?? this.historico,
        previsao: previsao ?? this.previsao,
        fonte: fonte ?? this.fonte,
        comoCalculamos: comoCalculamos,
        sintetico: sintetico,
        casasDecimais: casasDecimais,
      );
}

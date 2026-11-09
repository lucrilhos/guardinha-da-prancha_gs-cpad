/// Tipos de ocorrência que o cidadão pode registrar.
enum TipoOcorrencia {
  alagamentoRua('Alagamento de rua'),
  corregoTransbordando('Córrego transbordando'),
  bueiroEntupido('Bueiro entupido'),
  faltaDagua('Falta d\'água'),
  deslizamento('Deslizamento ou erosão');

  const TipoOcorrencia(this.rotulo);

  final String rotulo;
}

/// Regiões do ABC disponíveis no formulário.
/// O app guarda só a REGIÃO, nunca o endereço da pessoa.
const regioesAbc = [
  'São Bernardo do Campo – Centro',
  'São Bernardo do Campo – Rudge Ramos',
  'São Bernardo do Campo – Riacho Grande',
  'Santo André – Centro',
  'Santo André – Vila Luzita',
  'São Caetano do Sul – Centro',
  'Diadema – Eldorado',
  'Mauá – Centro',
];

/// Um relato anônimo feito pelo cidadão.
class Ocorrencia {
  const Ocorrencia({
    required this.id,
    required this.tipo,
    required this.regiao,
    required this.descricao,
    required this.gravidade,
    required this.criadaEm,
  });

  final String id;
  final TipoOcorrencia tipo;
  final String regiao;

  /// Texto já anonimizado (sem telefone, e-mail ou CPF).
  final String descricao;

  /// 1 = baixa, 2 = média, 3 = alta.
  final int gravidade;
  final DateTime criadaEm;

  String get rotuloGravidade => switch (gravidade) {
        3 => 'Alta',
        2 => 'Média',
        _ => 'Baixa',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.name,
        'regiao': regiao,
        'descricao': descricao,
        'gravidade': gravidade,
        'criadaEm': criadaEm.toIso8601String(),
      };

  factory Ocorrencia.fromJson(Map<String, dynamic> json) => Ocorrencia(
        id: json['id'] as String,
        tipo: TipoOcorrencia.values.byName(json['tipo'] as String),
        regiao: json['regiao'] as String,
        descricao: json['descricao'] as String,
        gravidade: json['gravidade'] as int,
        criadaEm: DateTime.parse(json['criadaEm'] as String),
      );
}

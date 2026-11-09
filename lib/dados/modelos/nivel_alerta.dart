/// Níveis de criticidade, do mais leve ao mais grave.
/// NORMAL não gera alerta; os outros três geram.
enum NivelAlerta {
  normal('Normal', 0),
  atencao('ATENÇÃO', 1),
  alerta('ALERTA', 2),
  critico('CRÍTICO', 3);

  const NivelAlerta(this.rotulo, this.gravidade);

  final String rotulo;

  /// Número usado para ordenar (quanto maior, mais grave).
  final int gravidade;

  /// Sugestão de ação. Sempre um verbo brando: quem decide é uma pessoa.
  String get sugestao => switch (this) {
        NivelAlerta.normal => 'Sem ação necessária. Siga acompanhando.',
        NivelAlerta.atencao => 'Acompanhar com mais frequência nas próximas horas.',
        NivelAlerta.alerta =>
          'Avaliar medidas preventivas: avisar moradores das áreas baixas e verificar bueiros.',
        NivelAlerta.critico =>
          'Avaliação prioritária pela Defesa Civil: considerar acionar equipes e orientar a população.',
      };
}

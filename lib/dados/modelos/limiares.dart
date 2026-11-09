import 'nivel_alerta.dart';

/// Três valores de corte (ATENÇÃO, ALERTA, CRÍTICO) para um indicador.
/// [inverso] = true quando quanto MENOR o valor, pior (ex.: volume do reservatório).
class Limiar {
  const Limiar({
    required this.atencao,
    required this.alerta,
    required this.critico,
    this.inverso = false,
  });

  final double atencao;
  final double alerta;
  final double critico;
  final bool inverso;

  /// Devolve o nível mais grave que o valor atingiu.
  NivelAlerta classificar(double valor) {
    if (inverso) {
      if (valor <= critico) return NivelAlerta.critico;
      if (valor <= alerta) return NivelAlerta.alerta;
      if (valor <= atencao) return NivelAlerta.atencao;
      return NivelAlerta.normal;
    }
    if (valor >= critico) return NivelAlerta.critico;
    if (valor >= alerta) return NivelAlerta.alerta;
    if (valor >= atencao) return NivelAlerta.atencao;
    return NivelAlerta.normal;
  }

  /// Valor de corte de um nível (para NORMAL devolve o de ATENÇÃO, a "porta de entrada").
  double valorDo(NivelAlerta nivel) => switch (nivel) {
        NivelAlerta.normal || NivelAlerta.atencao => atencao,
        NivelAlerta.alerta => alerta,
        NivelAlerta.critico => critico,
      };

  Map<String, dynamic> toJson() =>
      {'atencao': atencao, 'alerta': alerta, 'critico': critico, 'inverso': inverso};

  factory Limiar.fromJson(Map<String, dynamic> json) => Limiar(
        atencao: (json['atencao'] as num).toDouble(),
        alerta: (json['alerta'] as num).toDouble(),
        critico: (json['critico'] as num).toDouble(),
        inverso: json['inverso'] as bool? ?? false,
      );
}

/// Todos os limiares do app. Ficam salvos no aparelho e podem ser ajustados no formulário.
class Limiares {
  const Limiares({
    required this.chuva24h,
    required this.nivelCorrego,
    required this.reservatorio,
  });

  /// Chuva prevista para as próximas 24 h, em mm.
  final Limiar chuva24h;

  /// Nível do córrego, em metros (a margem fica em 4 m).
  final Limiar nivelCorrego;

  /// Volume útil do reservatório, em % (inverso: quanto menor, pior).
  final Limiar reservatorio;

  /// Valores de partida do grupo (não são oficiais; ver README).
  static const padrao = Limiares(
    chuva24h: Limiar(atencao: 30, alerta: 50, critico: 80),
    nivelCorrego: Limiar(atencao: 2.0, alerta: 3.0, critico: 3.8),
    reservatorio: Limiar(atencao: 60, alerta: 40, critico: 30, inverso: true),
  );

  Map<String, dynamic> toJson() => {
        'chuva24h': chuva24h.toJson(),
        'nivelCorrego': nivelCorrego.toJson(),
        'reservatorio': reservatorio.toJson(),
      };

  factory Limiares.fromJson(Map<String, dynamic> json) => Limiares(
        chuva24h: Limiar.fromJson(json['chuva24h'] as Map<String, dynamic>),
        nivelCorrego: Limiar.fromJson(json['nivelCorrego'] as Map<String, dynamic>),
        reservatorio: Limiar.fromJson(json['reservatorio'] as Map<String, dynamic>),
      );
}

/// Uma linha horizontal de limite para desenhar no gráfico (ex.: ALERTA = 3 m).
class LinhaLimite {
  const LinhaLimite(this.valor, this.nivel);

  final double valor;
  final NivelAlerta nivel;
}

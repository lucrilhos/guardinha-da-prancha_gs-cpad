import 'indicador.dart';
import 'nivel_alerta.dart';

/// Um alerta preditivo. Além do nível, carrega TUDO que explica o porquê:
/// evidências, nível de confiança e limitações.
class Alerta {
  const Alerta({
    required this.id,
    required this.indicadorId,
    required this.dominio,
    required this.nivel,
    required this.titulo,
    required this.resumo,
    required this.evidencias,
    required this.confianca,
    required this.limitacoes,
    required this.valorPrevisto,
    required this.limite,
    required this.unidade,
    required this.geradoEm,
    this.eventoPrevistoEm,
  });

  final String id;
  final String indicadorId;
  final Dominio dominio;
  final NivelAlerta nivel;
  final String titulo;

  /// Uma frase que resume o alerta.
  final String resumo;

  /// Os fatos (números) que levaram ao alerta.
  final List<String> evidencias;

  /// De 0 a 1. Quanto o grupo confia nesta previsão (ver README, seção Dados e alertas).
  final double confianca;

  /// O que a previsão NÃO considera / quando ela erra.
  final List<String> limitacoes;

  final double valorPrevisto;
  final double limite;
  final String unidade;
  final DateTime geradoEm;

  /// Quando o problema deve acontecer (usado para medir a antecedência).
  final DateTime? eventoPrevistoEm;

  String get rotuloConfianca {
    if (confianca >= 0.75) return 'Alta';
    if (confianca >= 0.5) return 'Média';
    return 'Baixa';
  }

  /// Horas entre o aviso e o evento previsto (null se não se aplica).
  double? get antecedenciaHoras {
    final evento = eventoPrevistoEm;
    if (evento == null) return null;
    final minutos = evento.difference(geradoEm).inMinutes;
    return minutos <= 0 ? 0 : minutos / 60;
  }
}

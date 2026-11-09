/// Validações dos formulários. Cada função devolve a MENSAGEM DE ERRO,
/// ou null quando o valor está certo (é o formato que o TextFormField espera).
library;

class Validadores {
  const Validadores._();

  static const minDescricao = 15;
  static const maxDescricao = 280;

  static String? obrigatorio(Object? valor, String mensagem) => valor == null ? mensagem : null;

  static String? descricao(String? texto) {
    final t = texto?.trim() ?? '';
    if (t.isEmpty) return 'Descreva o que está acontecendo.';
    if (t.length < minDescricao) {
      return 'Escreva pelo menos $minDescricao caracteres (faltam ${minDescricao - t.length}).';
    }
    if (t.length > maxDescricao) return 'Use no máximo $maxDescricao caracteres.';
    return null;
  }

  /// Converte "2,5" ou "2.5" em número. Devolve null se não for número.
  static double? lerNumero(String? texto) {
    final t = texto?.trim().replaceAll(',', '.') ?? '';
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  /// Um limiar: precisa ser número, maior que zero e no máximo [maximo].
  static String? numeroLimiar(String? texto, {required double maximo}) {
    final valor = lerNumero(texto);
    if (valor == null) return 'Digite um número (ex.: 2,5).';
    if (valor <= 0) return 'Precisa ser maior que zero.';
    if (valor > maximo) return 'Precisa ser no máximo ${maximo.toStringAsFixed(0)}.';
    return null;
  }

  /// Confere a ordem dos três limiares.
  /// Normal: ATENÇÃO < ALERTA < CRÍTICO. Inverso (reservatório): ATENÇÃO > ALERTA > CRÍTICO.
  static String? ordemLimiares(double atencao, double alerta, double critico, {bool inverso = false}) {
    final ok = inverso ? (atencao > alerta && alerta > critico) : (atencao < alerta && alerta < critico);
    if (ok) return null;
    return inverso
        ? 'Para reservatórios a ordem é ATENÇÃO > ALERTA > CRÍTICO (quanto menor o volume, pior).'
        : 'A ordem precisa ser ATENÇÃO < ALERTA < CRÍTICO.';
  }
}

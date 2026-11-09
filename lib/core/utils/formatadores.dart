/// Funções pequenas de formatação no padrão brasileiro (vírgula decimal, dd/MM).
library;

String formatarNumero(double valor, {int casas = 1}) =>
    valor.toStringAsFixed(casas).replaceAll('.', ',');

String formatarValor(double valor, String unidade, {int casas = 1}) =>
    '${formatarNumero(valor, casas: casas)} $unidade';

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

/// Ex.: "10/11 16:00"
String formatarDataHora(DateTime d) =>
    '${_doisDigitos(d.day)}/${_doisDigitos(d.month)} ${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

/// Ex.: "10/11/2026"
String formatarData(DateTime d) => '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';

/// Ex.: "16:00"
String formatarHora(DateTime d) => '${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

/// Ex.: "há 3 h", "há 2 dias", "agora há pouco"
String formatarIdade(Duration idade) {
  if (idade.inMinutes < 60) return 'há poucos minutos';
  if (idade.inHours < 48) return 'há ${idade.inHours} h';
  return 'há ${idade.inDays} dias';
}

/// Ex.: "62%" a partir de 0.62
String formatarPorcentagem(double fracao) => '${(fracao * 100).round()}%';

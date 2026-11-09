/// Contas simples usadas nas previsões. Sem Flutter: dá para testar com `flutter test`.
library;

double soma(Iterable<double> valores) => valores.fold(0.0, (a, b) => a + b);

double media(List<double> valores) => valores.isEmpty ? 0 : soma(valores) / valores.length;

/// Resultado de uma reta y = inclinacao * x + intercepto ajustada aos pontos.
class Reta {
  const Reta(this.inclinacao, this.intercepto, this.r2);

  /// Quanto o valor muda a cada passo (ex.: p.p. por dia).
  final double inclinacao;
  final double intercepto;

  /// De 0 a 1: quão bem a reta descreve os pontos (1 = perfeito).
  final double r2;

  double valorEm(double x) => inclinacao * x + intercepto;
}

/// Regressão linear (mínimos quadrados) com x = 0, 1, 2, ...
Reta regressaoLinear(List<double> y) {
  final n = y.length;
  if (n < 2) return Reta(0, n == 1 ? y.first : 0, 0);
  final mediaX = (n - 1) / 2;
  final mediaY = media(y);
  var sxy = 0.0;
  var sxx = 0.0;
  for (var i = 0; i < n; i++) {
    sxy += (i - mediaX) * (y[i] - mediaY);
    sxx += (i - mediaX) * (i - mediaX);
  }
  final inclinacao = sxy / sxx;
  final intercepto = mediaY - inclinacao * mediaX;

  // R² = 1 - (erro da reta / variação total)
  var erro = 0.0;
  var total = 0.0;
  for (var i = 0; i < n; i++) {
    final previsto = inclinacao * i + intercepto;
    erro += (y[i] - previsto) * (y[i] - previsto);
    total += (y[i] - mediaY) * (y[i] - mediaY);
  }
  final r2 = total == 0 ? 1.0 : (1 - erro / total).clamp(0.0, 1.0).toDouble();
  return Reta(inclinacao, intercepto, r2);
}

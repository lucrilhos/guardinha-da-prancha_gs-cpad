/// Remove dados pessoais que a pessoa possa ter digitado sem querer
/// (e-mail, CPF e telefone) antes de qualquer coisa ser salva.
library;

class ResultadoAnonimizacao {
  const ResultadoAnonimizacao(this.texto, this.removidos);

  final String texto;

  /// O que foi removido (ex.: ['telefone']). Vazio = nada removido.
  final List<String> removidos;

  bool get alterou => removidos.isNotEmpty;
}

class Anonimizador {
  const Anonimizador._();

  static const marcador = '[removido]';

  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+');
  static final _cpf = RegExp(r'\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b');
  // (11) 91234-5678 | 11 91234 5678 | 912345678 | 4123-4567
  static final _telefone = RegExp(r'(\(?\b\d{2}\)?\s?)?\b9?\d{4}[-\s]?\d{4}\b');

  static ResultadoAnonimizacao anonimizar(String texto) {
    var resultado = texto;
    final removidos = <String>[];

    // a ordem importa: CPF antes de telefone (senão parte do CPF parece telefone)
    for (final (regra, nome) in [(_email, 'e-mail'), (_cpf, 'CPF'), (_telefone, 'telefone')]) {
      if (regra.hasMatch(resultado)) {
        resultado = resultado.replaceAll(regra, marcador);
        removidos.add(nome);
      }
    }
    return ResultadoAnonimizacao(resultado, removidos);
  }
}

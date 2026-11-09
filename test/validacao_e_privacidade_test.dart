import 'package:flutter_test/flutter_test.dart';
import 'package:guardinha_da_prancha/logica/anonimizador.dart';
import 'package:guardinha_da_prancha/logica/estatistica.dart';
import 'package:guardinha_da_prancha/logica/validadores.dart';

void main() {
  group('Validadores do formulário de ocorrência', () {
    test('descrição vazia ou curta demais é recusada', () {
      expect(Validadores.descricao(''), isNotNull);
      expect(Validadores.descricao('alagou'), contains('pelo menos'));
    });

    test('descrição com tamanho certo é aceita', () {
      expect(Validadores.descricao('Água na altura da calçada perto da praça'), isNull);
    });

    test('descrição longa demais é recusada', () {
      expect(Validadores.descricao('a' * (Validadores.maxDescricao + 1)), isNotNull);
    });
  });

  group('Validadores do formulário de limiares', () {
    test('aceita número com vírgula', () {
      expect(Validadores.lerNumero('2,5'), 2.5);
      expect(Validadores.numeroLimiar('2,5', maximo: 4.6), isNull);
    });

    test('recusa texto, zero, negativo e acima do máximo', () {
      expect(Validadores.numeroLimiar('abc', maximo: 100), isNotNull);
      expect(Validadores.numeroLimiar('0', maximo: 100), isNotNull);
      expect(Validadores.numeroLimiar('-3', maximo: 100), isNotNull);
      expect(Validadores.numeroLimiar('150', maximo: 100), isNotNull);
    });

    test('confere a ordem normal e a inversa', () {
      expect(Validadores.ordemLimiares(30, 50, 80), isNull);
      expect(Validadores.ordemLimiares(50, 30, 80), isNotNull);
      expect(Validadores.ordemLimiares(60, 40, 30, inverso: true), isNull);
      expect(Validadores.ordemLimiares(30, 40, 60, inverso: true), isNotNull);
    });
  });

  group('Anonimizador', () {
    test('remove telefone, e-mail e CPF digitados por engano', () {
      // Arrange
      const texto = 'Alagou tudo, me liga (11) 91234-5678 ou fulano@email.com, CPF 123.456.789-09';

      // Act
      final resultado = Anonimizador.anonimizar(texto);

      // Assert
      expect(resultado.texto, isNot(contains('91234')));
      expect(resultado.texto, isNot(contains('@')));
      expect(resultado.texto, isNot(contains('123.456')));
      expect(resultado.removidos, containsAll(['telefone', 'e-mail', 'CPF']));
    });

    test('não mexe em texto sem dados pessoais', () {
      const texto = 'Bueiro entupido na esquina, água subindo desde as 15h';
      final resultado = Anonimizador.anonimizar(texto);
      expect(resultado.texto, texto);
      expect(resultado.alterou, isFalse);
    });
  });

  group('Estatística', () {
    test('regressão linear acha a reta certa', () {
      // Arrange: y = 2x + 1
      final y = [1.0, 3.0, 5.0, 7.0, 9.0];

      // Act
      final reta = regressaoLinear(y);

      // Assert
      expect(reta.inclinacao, closeTo(2, 1e-9));
      expect(reta.intercepto, closeTo(1, 1e-9));
      expect(reta.r2, closeTo(1, 1e-9));
    });
  });
}

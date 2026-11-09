import 'package:flutter_test/flutter_test.dart';
import 'package:guardinha_da_prancha/dados/fontes/reservatorios_local.dart';
import 'package:guardinha_da_prancha/dados/modelos/indicador.dart';
import 'package:guardinha_da_prancha/dados/modelos/limiares.dart';
import 'package:guardinha_da_prancha/dados/modelos/nivel_alerta.dart';
import 'package:guardinha_da_prancha/logica/motor_alertas.dart';

/// Testes da regra mais importante do app: QUANDO alertar e COMO justificar.
/// Padrão AAA: Arrange (preparar), Act (executar), Assert (conferir).
void main() {
  const motor = MotorAlertas();
  final agora = DateTime(2026, 11, 10, 12);

  Indicador chuvaPrevista(List<double> porHora) => Indicador(
        id: 'clima-chuva',
        dominio: Dominio.clima,
        titulo: 'Chuva por hora',
        local: 'Ponto de teste',
        unidade: 'mm',
        historico: [for (var h = 24; h >= 0; h--) PontoSerie(agora.subtract(Duration(hours: h)), 0)],
        previsao: [
          for (var i = 0; i < porHora.length; i++) PontoSerie(agora.add(Duration(hours: i + 1)), porHora[i]),
        ],
        fonte: 'teste',
        comoCalculamos: 'teste',
      );

  Indicador corrego({required List<double> historico, required List<double> previsao}) => Indicador(
        id: 'corrego-teste',
        dominio: Dominio.corregos,
        titulo: 'Córrego de teste',
        local: 'Ponto de teste',
        unidade: 'm',
        historico: [
          for (var i = 0; i < historico.length; i++)
            PontoSerie(agora.subtract(Duration(hours: historico.length - 1 - i)), historico[i]),
        ],
        previsao: [for (var i = 0; i < previsao.length; i++) PontoSerie(agora.add(Duration(hours: i + 1)), previsao[i])],
        fonte: 'teste',
        comoCalculamos: 'teste',
        sintetico: true,
      );

  Indicador reservatorio(double inicio, double variacaoPorDia) {
    final historico = [
      for (var d = 0; d < 60; d++) PontoSerie(DateTime(2026, 9, 1).add(Duration(days: d)), inicio + variacaoPorDia * d),
    ];
    return Indicador(
      id: 'reservatorio-teste',
      dominio: Dominio.reservatorios,
      titulo: 'Reservatório de teste',
      local: 'teste',
      unidade: '%',
      historico: historico,
      previsao: ReservatoriosLocal.projetar(historico),
      fonte: 'teste',
      comoCalculamos: 'teste',
    );
  }

  group('Alerta de chuva', () {
    test('gera ALERTA quando a chuva prevista em 24 h passa de 50 mm', () {
      // Arrange: 24 horas de 2,5 mm = 60 mm
      final chuva = chuvaPrevista(List.filled(24, 2.5));

      // Act
      final alerta = motor.alertaChuva(chuva, null, Limiares.padrao.chuva24h, agora, const ContextoDados());

      // Assert
      expect(alerta, isNotNull);
      expect(alerta!.nivel, NivelAlerta.alerta);
      expect(alerta.valorPrevisto, closeTo(60, 0.001));
      expect(alerta.evidencias, isNotEmpty);
      expect(alerta.limitacoes, isNotEmpty);
      expect(alerta.confianca, inInclusiveRange(0, 1));
    });

    test('não gera alerta quando a chuva prevista é fraca', () {
      // Arrange: 24 horas de 0,5 mm = 12 mm
      final chuva = chuvaPrevista(List.filled(24, 0.5));

      // Act
      final alerta = motor.alertaChuva(chuva, null, Limiares.padrao.chuva24h, agora, const ContextoDados());

      // Assert
      expect(alerta, isNull);
    });

    test('fica em silêncio com menos de 6 horas de previsão, mesmo com chuva forte', () {
      // Arrange: só 5 horas previstas
      final chuva = chuvaPrevista(List.filled(5, 30));

      // Act
      final alerta = motor.alertaChuva(chuva, null, Limiares.padrao.chuva24h, agora, const ContextoDados());

      // Assert
      expect(alerta, isNull);
    });

    test('dados que não são ao vivo diminuem a confiança e aparecem nas limitações', () {
      // Arrange
      final chuva = chuvaPrevista(List.filled(24, 4));
      const aoVivo = ContextoDados();
      const exemplo = ContextoDados(fatorConfianca: 0.4, observacoes: ['usando dados de exemplo']);

      // Act
      final alertaAoVivo = motor.alertaChuva(chuva, null, Limiares.padrao.chuva24h, agora, aoVivo)!;
      final alertaExemplo = motor.alertaChuva(chuva, null, Limiares.padrao.chuva24h, agora, exemplo)!;

      // Assert
      expect(alertaExemplo.confianca, lessThan(alertaAoVivo.confianca));
      expect(alertaExemplo.limitacoes, contains('usando dados de exemplo'));
    });
  });

  group('Alerta de córrego', () {
    test('gera CRÍTICO quando o nível previsto passa de 3,8 m', () {
      // Arrange
      final c = corrego(historico: [1.0, 1.2, 1.6, 2.1, 2.7, 3.2], previsao: [3.5, 3.9, 4.1]);

      // Act
      final alerta = motor.alertaCorrego(c, Limiares.padrao.nivelCorrego, agora, const ContextoDados());

      // Assert
      expect(alerta?.nivel, NivelAlerta.critico);
      expect(alerta?.eventoPrevistoEm, agora.add(const Duration(hours: 3)));
    });

    test('fica em silêncio com menos de 6 leituras', () {
      // Arrange
      final c = corrego(historico: [3.0, 3.5, 3.9], previsao: [4.2]);

      // Act
      final alerta = motor.alertaCorrego(c, Limiares.padrao.nivelCorrego, agora, const ContextoDados());

      // Assert
      expect(alerta, isNull);
    });
  });

  group('Alerta de reservatório (limiar inverso)', () {
    test('volume caindo gera alerta com a projeção de 30 dias', () {
      // Arrange: começa em 75% e perde 0,5 p.p. por dia -> hoje 45,5%, daqui a 30 dias ~30,5%
      final r = reservatorio(75, -0.5);

      // Act
      final alerta = motor.alertaReservatorio(r, Limiares.padrao.reservatorio, agora);

      // Assert
      expect(alerta, isNotNull);
      expect(alerta!.nivel, NivelAlerta.alerta);
      expect(alerta.confianca, greaterThanOrEqualTo(0.75)); // reta perfeita (R² = 1)
    });

    test('volume alto e subindo não gera alerta', () {
      // Arrange
      final r = reservatorio(70, 0.2);

      // Act
      final alerta = motor.alertaReservatorio(r, Limiares.padrao.reservatorio, agora);

      // Assert
      expect(alerta, isNull);
    });
  });

  test('gerarTodos devolve os alertas do mais grave para o mais leve', () {
    // Arrange: chuva de 60 mm (ALERTA) e córrego a 4,1 m (CRÍTICO)
    final chuva = chuvaPrevista(List.filled(24, 2.5));
    final c = corrego(historico: [1.0, 1.2, 1.6, 2.1, 2.7, 3.2], previsao: [3.5, 3.9, 4.1]);

    // Act
    final alertas = motor.gerarTodos(
      clima: [chuva],
      corregos: [c],
      reservatorios: const [],
      limiares: Limiares.padrao,
      agora: agora,
    );

    // Assert
    expect(alertas.map((a) => a.nivel).toList(), [NivelAlerta.critico, NivelAlerta.alerta]);
  });

  test('Limiar inverso classifica do jeito certo (quanto menor, pior)', () {
    const limiar = Limiar(atencao: 60, alerta: 40, critico: 30, inverso: true);
    expect(limiar.classificar(75), NivelAlerta.normal);
    expect(limiar.classificar(60), NivelAlerta.atencao);
    expect(limiar.classificar(35), NivelAlerta.alerta);
    expect(limiar.classificar(10), NivelAlerta.critico);
  });
}

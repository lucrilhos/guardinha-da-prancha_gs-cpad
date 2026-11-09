import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardinha_da_prancha/componentes/chip_nivel.dart';
import 'package:guardinha_da_prancha/dados/fontes/armazenamento_local.dart';
import 'package:guardinha_da_prancha/dados/modelos/nivel_alerta.dart';
import 'package:guardinha_da_prancha/dados/modelos/ocorrencia.dart';
import 'package:guardinha_da_prancha/estado/ocorrencias_provider.dart';
import 'package:guardinha_da_prancha/telas/ocorrencias/ocorrencia_form_tela.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ArmazenamentoLocal armazenamento;

  setUp(() async {
    SharedPreferences.setMockInitialValues({}); // "aparelho" vazio e falso, só para o teste
    armazenamento = ArmazenamentoLocal(await SharedPreferences.getInstance());
  });

  testWidgets('formulário vazio mostra as mensagens de erro e não salva nada', (tester) async {
    // Arrange
    final ocorrencias = OcorrenciasProvider(armazenamento);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ocorrencias,
        child: const MaterialApp(home: OcorrenciaFormTela()),
      ),
    );

    // Act: tenta enviar sem preencher nada
    final botao = find.byKey(const Key('botao-enviar-ocorrencia'));
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pump();

    // Assert
    expect(find.text('Escolha o tipo de ocorrência.'), findsOneWidget);
    expect(find.text('Escolha a região.'), findsOneWidget);
    expect(find.text('Descreva o que está acontecendo.'), findsOneWidget);
    expect(find.text('É preciso concordar para enviar o relato.'), findsOneWidget);
    expect(ocorrencias.total, 0);
  });

  test('registrar ocorrência apaga o telefone antes de salvar no aparelho', () async {
    // Arrange
    final ocorrencias = OcorrenciasProvider(armazenamento);

    // Act
    final resultado = await ocorrencias.registrar(
      tipo: TipoOcorrencia.alagamentoRua,
      regiao: regioesAbc.first,
      descricao: 'Rua alagada, qualquer coisa liga 11 91234-5678',
      gravidade: 3,
    );

    // Assert: o que ficou salvo no "aparelho" não tem o número
    final salvas = armazenamento.lerOcorrencias();
    expect(resultado.removidos, contains('telefone'));
    expect(salvas, hasLength(1));
    expect(salvas.first.descricao, isNot(contains('91234')));
  });

  testWidgets('etiqueta de nível mostra texto (não só cor) e tem rótulo para leitor de tela', (tester) async {
    // Arrange + Act
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ChipNivel(NivelAlerta.critico))));

    // Assert
    expect(find.text('CRÍTICO'), findsOneWidget);
    expect(find.bySemanticsLabel('Nível CRÍTICO'), findsOneWidget);
  });
}

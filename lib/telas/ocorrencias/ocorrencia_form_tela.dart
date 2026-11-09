import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/basicos.dart';
import '../../core/tema/espacos.dart';
import '../../dados/modelos/ocorrencia.dart';
import '../../estado/ocorrencias_provider.dart';
import '../../logica/validadores.dart';

/// FORMULÁRIO com validação: o cidadão registra uma ocorrência de forma anônima.
class OcorrenciaFormTela extends StatefulWidget {
  const OcorrenciaFormTela({super.key});

  @override
  State<OcorrenciaFormTela> createState() => _OcorrenciaFormTelaState();
}

class _OcorrenciaFormTelaState extends State<OcorrenciaFormTela> {
  // estado LOCAL do formulário
  final _formulario = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  TipoOcorrencia? _tipo;
  String? _regiao;
  int _gravidade = 2;
  bool _enviando = false;
  bool _tentouEnviar = false;

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _tentouEnviar = true);
    if (!_formulario.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confira os campos destacados em vermelho.')),
      );
      return;
    }

    setState(() => _enviando = true);
    final mensageiro = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final resultado = await context.read<OcorrenciasProvider>().registrar(
          tipo: _tipo!,
          regiao: _regiao!,
          descricao: _descricao.text,
          gravidade: _gravidade,
        );

    mensageiro.showSnackBar(SnackBar(
      content: Text(resultado.alterou
          ? 'Ocorrência registrada. Para proteger sua privacidade, removemos: ${resultado.removidos.join(', ')}.'
          : 'Ocorrência registrada de forma anônima. Obrigado!'),
    ));
    navegador.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ocorrência')),
      body: Form(
        key: _formulario,
        autovalidateMode: _tentouEnviar ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(Espaco.m),
          children: [
            ConteudoCentral(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Seu relato é anônimo: não pedimos nome, telefone nem endereço — só a região.',
                    style: tema.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Espaco.g),
                  DropdownButtonFormField<TipoOcorrencia>(
                    initialValue: _tipo,
                    decoration: const InputDecoration(labelText: 'Tipo de ocorrência *'),
                    items: [
                      for (final tipo in TipoOcorrencia.values) DropdownMenuItem(value: tipo, child: Text(tipo.rotulo)),
                    ],
                    onChanged: (valor) => setState(() => _tipo = valor),
                    validator: (valor) => Validadores.obrigatorio(valor, 'Escolha o tipo de ocorrência.'),
                  ),
                  const SizedBox(height: Espaco.m),
                  DropdownButtonFormField<String>(
                    initialValue: _regiao,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Região *',
                      helperText: 'Usamos só a região, nunca o endereço.',
                    ),
                    items: [
                      for (final regiao in regioesAbc)
                        DropdownMenuItem(value: regiao, child: Text(regiao, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (valor) => setState(() => _regiao = valor),
                    validator: (valor) => Validadores.obrigatorio(valor, 'Escolha a região.'),
                  ),
                  const SizedBox(height: Espaco.m),
                  Text('Gravidade percebida', style: tema.textTheme.labelLarge),
                  const SizedBox(height: Espaco.p),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Baixa')),
                      ButtonSegment(value: 2, label: Text('Média')),
                      ButtonSegment(value: 3, label: Text('Alta')),
                    ],
                    selected: {_gravidade},
                    onSelectionChanged: (selecao) => setState(() => _gravidade = selecao.first),
                  ),
                  const SizedBox(height: Espaco.m),
                  TextFormField(
                    controller: _descricao,
                    maxLines: 4,
                    maxLength: Validadores.maxDescricao,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'O que está acontecendo? *',
                      helperText: 'Ex.: "Água na altura da calçada perto da praça". Não escreva dados pessoais.',
                      helperMaxLines: 2,
                      alignLabelWithHint: true,
                    ),
                    validator: Validadores.descricao,
                  ),
                  const SizedBox(height: Espaco.p),
                  FormField<bool>(
                    initialValue: false,
                    validator: (valor) =>
                        valor == true ? null : 'É preciso concordar para enviar o relato.',
                    builder: (campo) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          value: campo.value ?? false,
                          onChanged: campo.didChange,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Concordo em enviar este relato de forma anônima, guardado só neste aparelho.'),
                        ),
                        if (campo.hasError)
                          Text(campo.errorText!, style: TextStyle(color: tema.colorScheme.error)),
                      ],
                    ),
                  ),
                  const SizedBox(height: Espaco.g),
                  FilledButton.icon(
                    key: const Key('botao-enviar-ocorrencia'),
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: Text(_enviando ? 'Enviando...' : 'Enviar ocorrência'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

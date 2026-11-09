import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../core/tema/espacos.dart';
import '../../core/utils/formatadores.dart';
import '../../dados/modelos/limiares.dart';
import '../../estado/preferencias_provider.dart';
import '../../estado/territorio_provider.dart';
import '../../logica/validadores.dart';

/// FORMULÁRIO de configuração dos limiares de alerta (validado e salvo no aparelho).
class LimiaresTela extends StatefulWidget {
  const LimiaresTela({super.key});

  @override
  State<LimiaresTela> createState() => _LimiaresTelaState();
}

/// Os três campos (ATENÇÃO, ALERTA, CRÍTICO) de um indicador.
class _CamposLimiar {
  _CamposLimiar(Limiar limiar)
      : atencao = TextEditingController(text: formatarNumero(limiar.atencao)),
        alerta = TextEditingController(text: formatarNumero(limiar.alerta)),
        critico = TextEditingController(text: formatarNumero(limiar.critico));

  final TextEditingController atencao;
  final TextEditingController alerta;
  final TextEditingController critico;
  String? erroOrdem;

  void preencher(Limiar limiar) {
    atencao.text = formatarNumero(limiar.atencao);
    alerta.text = formatarNumero(limiar.alerta);
    critico.text = formatarNumero(limiar.critico);
    erroOrdem = null;
  }

  /// Só chamar depois que os campos passaram na validação (são números).
  Limiar paraLimiar({bool inverso = false}) => Limiar(
        atencao: Validadores.lerNumero(atencao.text)!,
        alerta: Validadores.lerNumero(alerta.text)!,
        critico: Validadores.lerNumero(critico.text)!,
        inverso: inverso,
      );

  void dispose() {
    atencao.dispose();
    alerta.dispose();
    critico.dispose();
  }
}

class _LimiaresTelaState extends State<LimiaresTela> {
  final _formulario = GlobalKey<FormState>();
  late final _CamposLimiar _chuva;
  late final _CamposLimiar _corrego;
  late final _CamposLimiar _reservatorio;

  @override
  void initState() {
    super.initState();
    final atuais = context.read<PreferenciasProvider>().limiares;
    _chuva = _CamposLimiar(atuais.chuva24h);
    _corrego = _CamposLimiar(atuais.nivelCorrego);
    _reservatorio = _CamposLimiar(atuais.reservatorio);
  }

  @override
  void dispose() {
    _chuva.dispose();
    _corrego.dispose();
    _reservatorio.dispose();
    super.dispose();
  }

  void _restaurarPadroes() {
    setState(() {
      _chuva.preencher(Limiares.padrao.chuva24h);
      _corrego.preencher(Limiares.padrao.nivelCorrego);
      _reservatorio.preencher(Limiares.padrao.reservatorio);
    });
  }

  Future<void> _salvar() async {
    // 1) cada campo: é número? está na faixa?
    final camposOk = _formulario.currentState!.validate();
    if (!camposOk) return;

    // 2) cada grupo: a ordem dos três valores faz sentido?
    final chuva = _chuva.paraLimiar();
    final corrego = _corrego.paraLimiar();
    final reservatorio = _reservatorio.paraLimiar(inverso: true);
    setState(() {
      _chuva.erroOrdem = Validadores.ordemLimiares(chuva.atencao, chuva.alerta, chuva.critico);
      _corrego.erroOrdem = Validadores.ordemLimiares(corrego.atencao, corrego.alerta, corrego.critico);
      _reservatorio.erroOrdem = Validadores.ordemLimiares(
          reservatorio.atencao, reservatorio.alerta, reservatorio.critico,
          inverso: true);
    });
    if (_chuva.erroOrdem != null || _corrego.erroOrdem != null || _reservatorio.erroOrdem != null) return;

    final mensageiro = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final territorio = context.read<TerritorioProvider>();
    await context
        .read<PreferenciasProvider>()
        .salvarLimiares(Limiares(chuva24h: chuva, nivelCorrego: corrego, reservatorio: reservatorio));
    territorio.recalcularAlertas();
    mensageiro.showSnackBar(const SnackBar(content: Text('Limiares salvos. Os alertas foram recalculados.')));
    navegador.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limiares de alerta'),
        actions: [
          TextButton(onPressed: _restaurarPadroes, child: const Text('Restaurar padrões')),
        ],
      ),
      body: Form(
        key: _formulario,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(Espaco.m),
          children: [
            ConteudoCentral(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('A partir de quais valores o app deve avisar? Mudar aqui recalcula os alertas na hora. '
                      'Os valores de fábrica são referências do grupo, não números oficiais.'),
                  _GrupoLimiar(
                    titulo: 'Chuva prevista em 24 horas',
                    unidade: 'mm',
                    explicacao: 'Quanto MAIOR a chuva prevista, mais grave.',
                    campos: _chuva,
                    maximo: 300,
                  ),
                  _GrupoLimiar(
                    titulo: 'Nível dos córregos',
                    unidade: 'm',
                    explicacao: 'A margem fica em 4 m. Quanto MAIOR o nível, mais grave.',
                    campos: _corrego,
                    maximo: 4.6,
                  ),
                  _GrupoLimiar(
                    titulo: 'Volume dos reservatórios',
                    unidade: '%',
                    explicacao: 'Aqui é ao contrário: quanto MENOR o volume, mais grave.',
                    campos: _reservatorio,
                    maximo: 100,
                  ),
                  const SizedBox(height: Espaco.g),
                  FilledButton.icon(
                    onPressed: _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar limiares'),
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

class _GrupoLimiar extends StatelessWidget {
  const _GrupoLimiar({
    required this.titulo,
    required this.unidade,
    required this.explicacao,
    required this.campos,
    required this.maximo,
  });

  final String titulo;
  final String unidade;
  final String explicacao;
  final _CamposLimiar campos;
  final double maximo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    Widget campo(String rotulo, TextEditingController controle) => Padding(
          padding: const EdgeInsets.only(top: Espaco.m),
          child: TextFormField(
            controller: controle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: rotulo, suffixText: unidade),
            validator: (texto) => Validadores.numeroLimiar(texto, maximo: maximo),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecaoTitulo(titulo),
        CartaoPadrao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(explicacao, style: tema.textTheme.bodySmall),
              campo('ATENÇÃO', campos.atencao),
              campo('ALERTA', campos.alerta),
              campo('CRÍTICO', campos.critico),
              if (campos.erroOrdem != null)
                Padding(
                  padding: const EdgeInsets.only(top: Espaco.p),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(campos.erroOrdem!, style: TextStyle(color: tema.colorScheme.error)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

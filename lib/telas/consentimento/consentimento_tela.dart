import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/aviso_decisao_humana.dart';
import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../core/tema/espacos.dart';
import '../../estado/preferencias_provider.dart';

/// Primeira tela: explica quais dados o app usa e pede consentimento EXPLÍCITO.
class ConsentimentoTela extends StatefulWidget {
  const ConsentimentoTela({super.key});

  @override
  State<ConsentimentoTela> createState() => _ConsentimentoTelaState();
}

class _ConsentimentoTelaState extends State<ConsentimentoTela> {
  bool _concordou = false; // estado local: só esta tela usa

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Espaco.g),
          children: [
            ConteudoCentral(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: LogoApp(tamanho: 96)),
                  const SizedBox(height: Espaco.m),
                  Semantics(
                    header: true,
                    child: Text('Guardinha da Prancha',
                        style: tema.textTheme.headlineMedium, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: Espaco.p),
                  Text(
                    'De olho no céu, nos córregos e nos reservatórios do ABC, '
                    'para avisar antes que a água vire problema.',
                    style: tema.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SecaoTitulo('Antes de começar'),
                  const CartaoPadrao(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quais dados o app usa'),
                        SizedBox(height: Espaco.p),
                        ListaMarcadores([
                          'Dados públicos de clima (Open-Meteo) e dos mananciais (Sabesp).',
                          'Leituras de córregos SIMULADAS pelo próprio app (não há sensores reais).',
                          'Os relatos que você enviar: só o tipo, a região e a descrição. '
                              'Nunca pedimos nome, telefone ou endereço.',
                          'Se você digitar sem querer um telefone, e-mail ou CPF, o app apaga antes de salvar.',
                          'Tudo fica guardado apenas neste aparelho. Você pode apagar a qualquer momento em Ajustes.',
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: Espaco.m),
                  const AvisoDecisaoHumana(),
                  const SizedBox(height: Espaco.m),
                  CheckboxListTile(
                    value: _concordou,
                    onChanged: (valor) => setState(() => _concordou = valor ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Li e concordo com o uso dos dados descrito acima.'),
                  ),
                  const SizedBox(height: Espaco.m),
                  FilledButton.icon(
                    onPressed: _concordou ? () => context.read<PreferenciasProvider>().definirConsentimento(true) : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Começar'),
                  ),
                  if (!_concordou)
                    Padding(
                      padding: const EdgeInsets.only(top: Espaco.p),
                      child: Text(
                        'Marque a caixa acima para continuar.',
                        style: tema.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
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

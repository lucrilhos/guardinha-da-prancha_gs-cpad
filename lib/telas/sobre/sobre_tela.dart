import 'package:flutter/material.dart';

import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../core/tema/espacos.dart';

/// Tela "Sobre o app e privacidade".
///
/// TAREFA DO ANTONIO (ver TAREFAS_ANTONIO.md, tarefa 1):
/// completar esta tela usando SÓ os componentes que já existem
/// (SecaoTitulo, CartaoPadrao, ListaMarcadores, LogoApp, AvisoDecisaoHumana).
class SobreTela extends StatelessWidget {
  const SobreTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o app')),
      body: ListView(
        padding: const EdgeInsets.all(Espaco.m),
        children: const [
          ConteudoCentral(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: LogoApp(tamanho: 80)),
                SecaoTitulo('Guardinha da Prancha'),
                CartaoPadrao(
                  child: Text('Painel de antecipação de chuva, córregos e reservatórios no ABC Paulista. '
                      'Projeto acadêmico – FIAP, Global Solution 2026.2.'),
                ),
                // TODO(Antonio): seções "Equipe", "Fontes de dados", "Privacidade",
                // "Acessibilidade" e "Decisão humana" — roteiro em TAREFAS_ANTONIO.md.
              ],
            ),
          ),
        ],
      ),
    );
  }
}

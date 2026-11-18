import 'package:flutter/material.dart';

import '../../componentes/aviso_decisao_humana.dart';
import '../../componentes/basicos.dart';
import '../../componentes/cartao_padrao.dart';
import '../../core/tema/espacos.dart';

/// Tela "Sobre o app e privacidade".
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
                  child: Text(
                    'Painel de antecipação de chuva, córregos e reservatórios no ABC Paulista. '
                    'Projeto acadêmico — FIAP, Global Solution 2026.2 (Territory Predictive Insights).',
                  ),
                ),
                SecaoTitulo('Equipe'),
                CartaoPadrao(
                  child: ListaMarcadores([
                    'Antonio Lucas Santana Tavares — RM 565516',
                    'Lucas Mendes Moraes — RM 563667',
                    'Curso: Ciência da Computação (2CCPO) — FIAP',
                  ]),
                ),
                SecaoTitulo('Fontes de dados'),
                CartaoPadrao(
                  child: ListaMarcadores([
                    'Clima: consumo de API meteorológica pública (Open-Meteo) com fallback offline.',
                    'Córregos e Reservatórios: séries históricas locais (Sabesp) e cenários simulados do ABC Paulista.',
                    'Ocorrências: registros comunitários inseridos pelos usuários para apoio à gestão territorial.',
                  ]),
                ),
                SecaoTitulo('Privacidade'),
                CartaoPadrao(
                  child: ListaMarcadores([
                    'Consentimento explícito solicitado no primeiro acesso antes de qualquer registro.',
                    'Anonimização automática de dados pessoais (telefone, e-mail e CPF) antes do armazenamento.',
                    'Armazenamento estritamente local no dispositivo, sem envio de dados pessoais a servidores externos.',
                  ]),
                ),
                SecaoTitulo('Acessibilidade'),
                CartaoPadrao(
                  child: ListaMarcadores([
                    'Suporte a tema escuro e modo de alto contraste.',
                    'Compatibilidade com leitores de tela (semântica dedicada) e ampliação dinâmica de fontes.',
                    'Layout responsivo adaptado a diferentes tamanhos e orientações de tela.',
                  ]),
                ),
                SecaoTitulo('Decisão humana'),
                AvisoDecisaoHumana(),
                SizedBox(height: Espaco.g),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
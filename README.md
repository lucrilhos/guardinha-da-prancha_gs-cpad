<p align="center">
  <img src="assets/marca/logo-main.png" alt="Logo do Guardinha da Prancha" width="140">
</p>

<h1 align="center">Guardinha da Prancha</h1>

<p align="center">
  Global Solution 2026.2 · Cross-Platform Application Development · FIAP · <i>Territory Predictive Insights</i>
</p>

> O nome é uma homenagem aos "guardinhas" que ficam de vigia e sinalizam quando algo está para acontecer, mas não em uma prancha!

---

## 1. Problema e público

**O problema:** No ABC Paulista, a água causa dois tipos de crise: **alagamentos** quando temporais de poucas horas fazem córregos como o Ribeirão dos Meninos e o Rio Tamanduateí transbordarem, e **risco de desabastecimento** quando os mananciais (como o Sistema Rio Grande, braço da Billings que abastece boa parte da região) entram em queda prolongada. Nos dois casos, o dano é maior quando o aviso chega tarde: quando a água já está na rua, não dá mais tempo de tirar o carro, os móveis e as pessoas com mobilidade reduzida.

**Para quem:**
- **Gestores públicos e Defesa Civil municipal:** veem num só lugar a chuva prevista, o nível dos córregos e o volume dos reservatórios, com alertas explicados e o grau de confiança de cada um.
- **Cidadãos das áreas de risco:** acompanham os alertas e **registram ocorrências** (alagamento, bueiro entupido, falta d'água) de forma anônima.

**Impacto social esperado:** Ganhar **horas de antecedência** para avisar moradores, liberar bueiros e posicionar equipes. O app mostra três indicadores de benefício social na tela inicial: a **antecedência média dos alertas**, os **moradores perto de córregos em alerta** e os **relatos da comunidade**.

---

## 2. Integrantes

| Nome completo | RM |
|---|---|
| Lucas M. Moraes | RM563667 |
| Antonio Lucas | RM565516 |

---

## 3. Demonstração visual

<!-- tirar os prints e salvar em assets/screenshots/; mudar nome posteriormente -->

| | | |
|:---:|:---:|:---:|
| <img src="assets/screenshots/01_consentimento.png" width="220"><br>**Consentimento** — dados usados e aceite explícito | <img src="assets/screenshots/02_inicio.png" width="220"><br>**Início** — alertas, painéis e impacto social | <img src="assets/screenshots/03_painel_clima.png" width="220"><br>**Painel de clima** — chuva medida e prevista |
| <img src="assets/screenshots/04_painel_corregos.png" width="220"><br>**Painel dos córregos** — nível e previsão de 6 h | <img src="assets/screenshots/05_painel_reservatorios.png" width="220"><br>**Painel dos reservatórios** — volume e projeção | <img src="assets/screenshots/06_indicador.png" width="220"><br>**Detalhe do indicador** — histórico, tendência e fonte |
| <img src="assets/screenshots/07_alertas.png" width="220"><br>**Alertas** — lista com filtro por painel | <img src="assets/screenshots/08_alerta_detalhe.png" width="220"><br>**Detalhe do alerta** — evidências, confiança e limitações | <img src="assets/screenshots/09_ocorrencias.png" width="220"><br>**Ocorrências** — relatos anônimos |
| <img src="assets/screenshots/10_ocorrencia_form.png" width="220"><br>**Nova ocorrência** — formulário com validação | <img src="assets/screenshots/11_limiares.png" width="220"><br>**Limiares** — configuração validada | <img src="assets/screenshots/12_ajustes.png" width="220"><br>**Ajustes** — temas, fonte e demonstração |
| <img src="assets/screenshots/13_sobre.png" width="220"><br>**Sobre e privacidade** | <img src="assets/screenshots/14_tema_escuro.png" width="220"><br>**Tema escuro** | <img src="assets/screenshots/15_alto_contraste.png" width="220"><br>**Alto contraste + fonte ampliada** |

---

## 4. Funcionalidades

**Navegação e telas**
- [x] 13 telas com **rotas nomeadas** e **passagem de parâmetros** (id do indicador e id do alerta)
- [x] Fluxo coerente: **Início → Painel → Detalhe do indicador → Detalhe do alerta**
- [x] Barra de navegação com 4 abas (Início, Alertas, Ocorrências, Ajustes) e contador de alertas

**Dashboards territoriais (3)**
- [x] **Clima**: chuva das últimas 24 h, chuva prevista para 24 h, hora mais chuvosa, temperatura e probabilidade de chuva, com gráficos de histórico + previsão
- [x] **Córregos**: nível atual, máximo previsto para 6 h e tendência de 3 córregos, com linhas de limite no gráfico
- [x] **Reservatórios**: volume útil do Sistema Rio Grande e do Sistema Integrado, tendência de 30 dias e projeção de 30 dias

**Alertas preditivos e transparência**
- [x] Alertas gerados a partir de regras sobre os dados **previstos** (ATENÇÃO, ALERTA, CRÍTICO)
- [x] Cada alerta mostra **evidências**, **nível de confiança** (barra + porcentagem + como foi calculado) e **limitações**
- [x] Aviso visível em todas as telas de alerta: **a decisão final é humana**
- [x] Botão "Marcar como avaliado por mim": a pessoa registra que analisou o alerta
- [x] O app **fica em silêncio** quando não há dados suficientes (não chuta)

**Estado, dados e persistência**
- [x] Estado global (Provider) compartilhado entre várias telas; estado local para abas, filtros e formulários
- [x] Estados de **carregamento**, **erro** (com "Tentar novamente") e **lista vazia** tratados
- [x] Consumo da **API real Open-Meteo** (clima) + dados públicos da **Sabesp** (mananciais)
- [x] Persistência local: ocorrências, limiares, preferências, alertas avaliados e **cache da API**
- [x] **Funciona sem internet**: usa o cache da última previsão (ou dados de exemplo) e avisa na tela de onde vêm os dados

**Formulários com validação**
- [x] **Registro de ocorrência** (tipo, região, gravidade, descrição e consentimento) com mensagens de erro claras
- [x] **Configuração de limiares** (número, faixa e ordem ATENÇÃO/ALERTA/CRÍTICO validados)

**Identidade visual, acessibilidade e privacidade**
- [x] Tema próprio (azul-petróleo + âmbar) e componentes reutilizáveis
- [x] **Tema escuro**, **alto contraste** e **tamanho de fonte ajustável** (até 160%, somado ao do sistema)
- [x] Rótulos para leitor de tela em cartões, gráficos, etiquetas de nível e botões
- [x] Consentimento explícito, dados anonimizados e botão "Apagar meus dados"
- [x] Layout responsivo (1, 2 ou 3 colunas conforme a largura da tela)

**Diferenciais**
- [x] Dados reais (Open-Meteo e Sabesp)
- [x] Temas (escuro e alto contraste)
- [x] Testes automatizados (lógica de alertas, validações, privacidade e widgets)
- [x] Animações com propósito (transição entre estados, barra de confiança)
- [ ] APK de release *(tarefa do Antonio — ver Releases)*

---

## 5. Dados e alertas

### Fontes de dados

| Painel | Fonte | Tipo | Como chega ao app |
|---|---|---|---|
| Clima | [Open-Meteo](https://open-meteo.com/) – chuva, probabilidade de chuva e temperatura hora a hora para o centro de São Bernardo do Campo (48 h passadas + 48 h de previsão) | **Público, real** | API HTTP gratuita, sem chave. A resposta é salva no aparelho (cache). |
| Córregos | Ribeirão dos Meninos, Ribeirão dos Couros e Rio Tamanduateí | **Sintético** | Gerado pelo app a partir da chuva: o córrego sobe de 1 a 6 h depois que chove (`nível = base + Σ peso × chuva de k horas atrás + ruído`). |
| Reservatórios | Sabesp – volume útil diário dos mananciais (Sistema Rio Grande e Sistema Integrado), 180 dias até 05/11/2026 | **Público, real** | Arquivo JSON empacotado em `assets/dados/` (funciona 100% offline). |

### Como os alertas são gerados (`lib/logica/motor_alertas.dart`)

| Painel | O que é previsto | Regra | Limiares padrão (ajustáveis) |
|---|---|---|---|
| Clima | Soma da chuva prevista para as próximas 24 h | valor ≥ limiar | ATENÇÃO 30 mm · ALERTA 50 mm · CRÍTICO 80 mm |
| Córregos | Maior nível previsto para as próximas 6 h (modelo de resposta à chuva prevista) | valor ≥ limiar | ATENÇÃO 2,0 m · ALERTA 3,0 m · CRÍTICO 3,8 m (margem em 4,0 m) |
| Reservatórios | Volume daqui a 30 dias (reta ajustada aos últimos 30 dias) | valor ≤ limiar (inverso) | ATENÇÃO 60% · ALERTA 40% · CRÍTICO 30% |

Os limiares são **referências do grupo**, inspiradas em faixas usuais de intensidade de chuva e nas faixas de operação de mananciais; **não são valores oficiais** e podem ser mudados no formulário de limiares.

### Métricas exibidas

- **Confiança (0–100%)**, calculada de forma diferente em cada painel e explicada no próprio alerta:
  - *Clima:* `0,2 + 0,7 × probabilidade média de chuva nas horas chuvosas`, reduzida em 15% se o pico está a mais de 12 h e multiplicada pelo fator de qualidade dos dados (ao vivo = 1; cache de 3–12 h = 0,8; cache antigo = 0,6; dados de exemplo = 0,4).
  - *Córregos:* parte de 55% (dado sintético), sobe 10 pontos se o córrego já está subindo; também multiplicada pelo fator de qualidade dos dados.
  - *Reservatórios:* `0,35 + 0,5 × R²` da reta (quanto melhor a reta descreve os 30 dias, maior a confiança), reduzida se os dados têm mais de 15 dias.
- **Antecedência (h):** tempo entre a emissão do alerta e o pico previsto (indicador de benefício social).
- **Tendência:** variação das últimas 3 h (clima e córregos) ou inclinação da reta em pontos percentuais por dia (reservatórios).

### Quando as previsões NÃO são confiáveis (e o que o app faz)

| Situação | O que o app faz |
|---|---|
| Menos de 6 horas de previsão de chuva, menos de 6 leituras de um córrego ou menos de 30 dias de um reservatório | **Não emite alerta** (fica em silêncio em vez de chutar) |
| Sem internet | Usa o cache e **reduz a confiança**; a tela mostra "Sem conexão: previsão salva há X h" |
| Sem internet e sem cache (primeiro uso offline) | Usa dados de exemplo, **confiança 40% menor**, aviso em destaque |
| Modo demonstração ligado | Faixa "MODO DEMONSTRAÇÃO" em todas as telas de dados e na lista de limitações |

### Limitações e possíveis vieses

- **Um ponto só de previsão do tempo:** a chuva é prevista para o centro de São Bernardo; bairros vizinhos podem receber muito mais ou muito menos. Temporais de verão muito localizados costumam ser **subestimados** pelos modelos globais.
- **Córregos sintéticos:** não há sensor real. O modelo não considera bueiros entupidos, lixo, obras nem o nível de rios maiores — justamente o que costuma piorar alagamentos em áreas mais pobres, onde a manutenção é menor. Isso pode gerar **viés de subestimação** exatamente onde o risco é maior.
- **Projeção linear dos reservatórios:** não antecipa uma sequência de chuvas fortes nem uma estiagem que começa agora, e não enxerga as manobras operacionais da Sabesp.
- **População estimada:** os números de moradores por córrego são **ilustrativos** (não vêm de censo) e servem só para mostrar o tipo de indicador social que o app pode exibir.
- **Relatos da comunidade** dependem de quem tem celular e tempo para registrar: bairros com menos acesso tendem a aparecer menos.

> **A decisão final é sempre humana.** O app nunca dispara sirene, evacuação ou interdição. Ele mostra a evidência, a confiança e as limitações, sugere uma avaliação com verbos brandos ("acompanhar", "avaliar") e deixa a decisão com a Defesa Civil e com os moradores.

---

## 6. Privacidade e inclusão

**Privacidade**
- **Consentimento explícito** na primeira abertura, explicando quais dados são usados; sem aceitar, o app não abre.
- **Minimização:** o formulário de ocorrência **não pede** nome, telefone, e-mail nem endereço — só tipo, **região** (lista fechada) e descrição.
- **Anonimização automática:** antes de salvar, o app remove telefones, e-mails e CPFs digitados por engano na descrição e avisa a pessoa (`lib/logica/anonimizador.dart`).
- **Tudo fica no aparelho** (shared_preferences). Nada é enviado a servidores; a única chamada externa é a previsão do tempo, que não leva nenhum dado da pessoa.
- **Direito de apagar:** Ajustes → "Apagar meus dados" remove ocorrências, avaliações e o consentimento.
- **Sem chaves de API** no código (a Open-Meteo não exige chave).

**Acessibilidade e inclusão**
- Contraste conferido (texto escuro sobre amarelo/laranja, branco sobre verde/vermelho) e **tema de alto contraste**.
- **Nível nunca indicado só por cor:** toda etiqueta tem ícone + texto (ATENÇÃO, ALERTA, CRÍTICO).
- **Fonte ajustável** no app (100–160%), somada ao tamanho de fonte do sistema; layouts que quebram linha em vez de cortar texto.
- **Leitor de tela:** rótulos (`Semantics`) em cartões, gráficos (o leitor fala valor atual, máximo previsto e limites), etiquetas de nível, barra de confiança e todos os botões de ícone (`tooltip`).
- Responsivo: 1 coluna no celular, 2 ou 3 em telas maiores; conteúdo limitado a 840 px em tablets.

---

## 7. Tecnologias e decisões técnicas

| Escolha | Por quê |
|---|---|
| **Flutter + Dart** | Exigência da disciplina; um código só para Android (e iOS, se necessário). |
| **provider** | Gerenciamento de estado mais simples de explicar (`ChangeNotifier` + `context.watch`), recomendado pela documentação do Flutter. Três estados globais: `PreferenciasProvider`, `TerritorioProvider` e `OcorrenciasProvider`. Estado local (`setState`) para aba selecionada, filtros e formulários. |
| **http** | Cliente HTTP oficial do Dart, suficiente para uma chamada GET à Open-Meteo. |
| **shared_preferences** | Persistência local simples: os dados do app são pequenos (preferências, limiares, algumas ocorrências e um JSON de cache). Um banco SQL seria exagero para esse volume. |
| **fl_chart** | Gráficos de linha com linhas de limite e trechos tracejados para previsão. |
| **flutter_localizations** | Componentes do sistema (botões, datas, leitores de tela) em português. |
| **Open-Meteo** | API de clima aberta, gratuita e **sem chave**: nada de credenciais no repositório. |
| **Dados da Sabesp em assets** | Dados reais que funcionam sem internet; o painel de reservatórios nunca fica vazio. |

**Arquitetura em camadas**

```
lib/
├── main.dart, app.dart, rotas.dart   → inicialização, temas e rotas nomeadas
├── core/                             → tema (cores, espaçamentos) e formatadores pt-BR
├── componentes/                      → widgets reutilizáveis (cartões, gráfico, chips, estados de tela...)
├── dados/
│   ├── modelos/                      → Indicador, Alerta, Ocorrencia, Limiares, NivelAlerta
│   └── fontes/                       → Open-Meteo, córregos simulados, Sabesp, armazenamento local
├── logica/                           → motor de alertas, validadores, anonimizador, estatística (sem Flutter: testável)
├── estado/                           → providers (estado global)
└── telas/                            → uma pasta por tela
test/                                 → testes de unidade e de widget
assets/                               → dados (JSON), marca (logo) e screenshots
```

A regra é: **telas** só mostram e chamam o **estado**; o estado usa as **fontes de dados** e a **lógica**; a lógica não conhece telas. Assim, o motor de alertas é testado sem abrir o app.

---

## 8. Como executar

**Pré-requisitos:** Flutter **3.35 ou mais novo** (`flutter --version`), Android Studio ou VS Code e um emulador Android ou celular com depuração USB.

```bash
# 1. clonar
git clone https://github.com/lucrilhos/NOME-DO-REPOSITORIO.git
cd NOME-DO-REPOSITORIO

# 2. instalar as dependências
flutter pub get

# 3. (opcional) conferir o código e rodar os testes
flutter analyze
flutter test

# 4. rodar
flutter run
```

**Variáveis de ambiente:** nenhuma. A Open-Meteo não exige chave de API.

**Dicas para testar tudo (também usadas no vídeo):** em **Ajustes → Demonstração**:
- *Cenário de tempestade e estiagem* → gera alertas nos três painéis com dados fictícios;
- *Simular sem conexão* → mostra o app usando o cache;
- *Simular falha total dos dados* → mostra a tela de erro com "Tentar novamente".

---

## 9. Vídeo

🎬 **[Assista à demonstração (até 3 minutos)](LINK_DO_VIDEO)**

---

## 10. Licença

Projeto acadêmico desenvolvido para a **FIAP – Global Solution 2026.2** (Cross-Platform Application Development). Uso educacional.

Dados de clima: [Open-Meteo](https://open-meteo.com/) (CC BY 4.0). Dados de mananciais: Sabesp (dados públicos).

---

## 11. Uso de IA

O grupo usou o **Claude (Anthropic)** como assistente: geração da primeira versão do código, dos testes e deste README a partir das decisões da equipe (tema, painéis, Provider, shared_preferences, identidade visual e nome). Revisamos rodando `flutter analyze`, `flutter test` e o app no emulador, testamos os modos sem conexão e de falha e lemos cada arquivo para conseguir explicá-lo.

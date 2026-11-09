import 'dart:math';

import '../core/utils/formatadores.dart';
import '../dados/fontes/corregos_simulados.dart';
import '../dados/fontes/reservatorios_local.dart';
import '../dados/modelos/alerta.dart';
import '../dados/modelos/indicador.dart';
import '../dados/modelos/limiares.dart';
import '../dados/modelos/nivel_alerta.dart';
import 'estatistica.dart';

/// Informações sobre a QUALIDADE dos dados de clima usados no cálculo.
class ContextoDados {
  const ContextoDados({this.fatorConfianca = 1.0, this.observacoes = const []});

  /// 1 = dados ao vivo. Menor que 1 = dados velhos ou de exemplo (a confiança cai).
  final double fatorConfianca;

  /// Limitações extras que entram em todos os alertas de clima e córregos.
  final List<String> observacoes;
}

/// Transforma dados em alertas. Regras:
/// 1. Só alerta quando o valor PREVISTO atinge um limiar.
/// 2. Todo alerta traz evidências, confiança e limitações.
/// 3. Com poucos dados, fica em SILÊNCIO (não gera alerta) em vez de chutar.
/// 4. Nunca decide nada: só sugere avaliação a uma pessoa.
class MotorAlertas {
  const MotorAlertas();

  /// Mínimo de horas de previsão de chuva para emitir alerta.
  static const minimoHorasPrevistas = 6;

  /// Mínimo de leituras de um córrego para emitir alerta.
  static const minimoLeiturasCorrego = 6;

  List<Alerta> gerarTodos({
    required List<Indicador> clima,
    required List<Indicador> corregos,
    required List<Indicador> reservatorios,
    required Limiares limiares,
    required DateTime agora,
    ContextoDados contextoClima = const ContextoDados(),
  }) {
    final alertas = <Alerta>[];

    final chuva = _porId(clima, 'clima-chuva');
    if (chuva != null) {
      final alerta = alertaChuva(chuva, _porId(clima, 'clima-probabilidade'), limiares.chuva24h, agora, contextoClima);
      if (alerta != null) alertas.add(alerta);
    }
    for (final corrego in corregos) {
      final alerta = alertaCorrego(corrego, limiares.nivelCorrego, agora, contextoClima);
      if (alerta != null) alertas.add(alerta);
    }
    for (final reservatorio in reservatorios) {
      final alerta = alertaReservatorio(reservatorio, limiares.reservatorio, agora);
      if (alerta != null) alertas.add(alerta);
    }

    // mais graves primeiro; empate -> maior confiança primeiro
    alertas.sort((a, b) {
      final porNivel = b.nivel.gravidade.compareTo(a.nivel.gravidade);
      return porNivel != 0 ? porNivel : b.confianca.compareTo(a.confianca);
    });
    return alertas;
  }

  // ------------------------------------------------------------------ CHUVA
  Alerta? alertaChuva(
    Indicador chuva,
    Indicador? probabilidade,
    Limiar limiar,
    DateTime agora,
    ContextoDados contexto,
  ) {
    final fim = agora.add(const Duration(hours: 24));
    final proximas = chuva.previsao.where((p) => p.momento.isAfter(agora) && !p.momento.isAfter(fim)).toList();
    if (proximas.length < minimoHorasPrevistas) return null; // silêncio: previsão curta demais

    final total = soma(proximas.map((p) => p.valor));
    final nivel = limiar.classificar(total);
    if (nivel == NivelAlerta.normal) return null;

    final pico = proximas.reduce((a, b) => b.valor > a.valor ? b : a);

    // confiança: começa pela probabilidade de chuva informada pelo modelo nas horas chuvosas
    final horasChuvosas = proximas.where((p) => p.valor >= 0.1).map((p) => p.momento).toSet();
    final probabilidades = probabilidade?.previsao
            .where((p) => horasChuvosas.contains(p.momento))
            .map((p) => p.valor)
            .toList() ??
        <double>[];
    final probabilidadeMedia = probabilidades.isEmpty ? 50.0 : media(probabilidades);
    var confianca = 0.2 + 0.7 * (probabilidadeMedia / 100);
    if (pico.momento.difference(agora).inHours > 12) confianca *= 0.85; // longe = menos preciso
    confianca = (confianca * contexto.fatorConfianca).clamp(0.05, 0.95).toDouble();

    final ultimas24h =
        chuva.historico.where((p) => p.momento.isAfter(agora.subtract(const Duration(hours: 24)))).map((p) => p.valor);

    return Alerta(
      id: _id('chuva', chuva.id, nivel, agora),
      indicadorId: chuva.id,
      dominio: Dominio.clima,
      nivel: nivel,
      titulo: 'Chuva forte prevista',
      resumo: 'Previsão de ${formatarValor(total, 'mm')} de chuva nas próximas 24 horas.',
      evidencias: [
        'Chuva prevista nas próximas 24 h: ${formatarValor(total, 'mm')} '
            '(limite de ${nivel.rotulo}: ${formatarValor(limiar.valorDo(nivel), 'mm', casas: 0)}).',
        'Hora mais chuvosa: ${formatarValor(pico.valor, 'mm')} em ${formatarDataHora(pico.momento)}.',
        'Probabilidade média de chuva nessas horas: ${probabilidadeMedia.round()}%.',
        'Chuva nas últimas 24 h: ${formatarValor(soma(ultimas24h), 'mm')} (solo molhado escoa mais água).',
      ],
      confianca: confianca,
      limitacoes: [
        'Previsão de um modelo meteorológico para um único ponto (${chuva.local}); '
            'outros bairros podem receber bem mais ou bem menos chuva.',
        'Temporais de verão muito localizados costumam ser subestimados pelos modelos.',
        'Quanto mais distante o horário previsto, menor a precisão.',
        ...contexto.observacoes,
      ],
      valorPrevisto: total,
      limite: limiar.valorDo(nivel),
      unidade: 'mm',
      geradoEm: agora,
      eventoPrevistoEm: pico.momento,
    );
  }

  // ------------------------------------------------------------------ CÓRREGOS
  Alerta? alertaCorrego(Indicador corrego, Limiar limiar, DateTime agora, ContextoDados contexto) {
    if (corrego.historico.length < minimoLeiturasCorrego || corrego.previsao.isEmpty) return null;

    final pico = corrego.previsao.reduce((a, b) => b.valor > a.valor ? b : a);
    final nivel = limiar.classificar(pico.valor);
    if (nivel == NivelAlerta.normal) return null;

    final atual = corrego.historico.last.valor;
    final tresHorasAtras = corrego.historico[corrego.historico.length - 4].valor;
    final ritmo = (atual - tresHorasAtras) / 3; // metros por hora

    // dado sintético: a confiança parte de "média" e sobe um pouco se o córrego JÁ está subindo
    var confianca = 0.55;
    if (ritmo > 0.05 && pico.valor > atual) confianca += 0.1;
    confianca = (confianca * contexto.fatorConfianca).clamp(0.05, 0.95).toDouble();

    final sentido = ritmo > 0.02
        ? 'subindo'
        : ritmo < -0.02
            ? 'descendo'
            : 'estável';

    return Alerta(
      id: _id('corrego', corrego.id, nivel, agora),
      indicadorId: corrego.id,
      dominio: Dominio.corregos,
      nivel: nivel,
      titulo: 'Risco de transbordamento – ${corrego.titulo}',
      resumo: 'Nível previsto de ${formatarValor(pico.valor, 'm', casas: 2)} em ${formatarHora(pico.momento)} '
          '(${corrego.local}).',
      evidencias: [
        'Nível agora: ${formatarValor(atual, 'm', casas: 2)}.',
        'Nível previsto: ${formatarValor(pico.valor, 'm', casas: 2)} em ${formatarDataHora(pico.momento)} '
            '(limite de ${nivel.rotulo}: ${formatarValor(limiar.valorDo(nivel), 'm')}; '
            'a margem fica em ${formatarValor(CorregosSimulados.margem, 'm')}).',
        'Ritmo nas últimas 3 h: ${ritmo >= 0 ? '+' : ''}${formatarNumero(ritmo, casas: 2)} m/h ($sentido).',
        'A previsão do nível usa a chuva prevista para as próximas horas.',
      ],
      confianca: confianca,
      limitacoes: [
        'Leituras SINTÉTICAS: não há sensor real instalado neste ponto.',
        'Modelo simples de resposta da bacia: não considera bueiros entupidos, lixo, obras '
            'nem o nível de rios maiores.',
        'Herda a incerteza da previsão de chuva.',
        ...contexto.observacoes,
      ],
      valorPrevisto: pico.valor,
      limite: limiar.valorDo(nivel),
      unidade: 'm',
      geradoEm: agora,
      eventoPrevistoEm: pico.momento,
    );
  }

  // ------------------------------------------------------------------ RESERVATÓRIOS
  Alerta? alertaReservatorio(Indicador reservatorio, Limiar limiar, DateTime agora) {
    final janela = ReservatoriosLocal.janelaDias;
    if (reservatorio.historico.length < janela || reservatorio.previsao.isEmpty) return null;

    final atual = reservatorio.historico.last;
    final projetado = reservatorio.previsao.last;
    final nivelAtual = limiar.classificar(atual.valor);
    final nivelProjetado = limiar.classificar(projetado.valor);
    final nivel = nivelProjetado.gravidade >= nivelAtual.gravidade ? nivelProjetado : nivelAtual;
    if (nivel == NivelAlerta.normal) return null;

    final ultimos = reservatorio.historico.sublist(reservatorio.historico.length - janela).map((p) => p.valor).toList();
    final reta = regressaoLinear(ultimos);
    final diasDeAtraso = agora.difference(atual.momento).inDays;

    var confianca = 0.35 + 0.5 * reta.r2; // reta que descreve bem os dados = mais confiança
    if (diasDeAtraso > 15) confianca *= 0.8; // dado antigo = menos confiança
    confianca = confianca.clamp(0.3, 0.85).toDouble();

    // quando o volume deve cruzar o limite (para medir a antecedência)
    DateTime? cruzamento;
    for (final p in reservatorio.previsao) {
      if (limiar.classificar(p.valor).gravidade >= nivel.gravidade) {
        cruzamento = p.momento;
        break;
      }
    }
    if (nivelAtual.gravidade >= nivel.gravidade) cruzamento = atual.momento;

    final sinal = reta.inclinacao >= 0 ? '+' : '';
    return Alerta(
      id: _id('reservatorio', reservatorio.id, nivel, atual.momento),
      indicadorId: reservatorio.id,
      dominio: Dominio.reservatorios,
      nivel: nivel,
      titulo: '${reta.inclinacao < 0 ? 'Volume em queda' : 'Volume baixo'} – ${reservatorio.titulo}',
      resumo: 'Projeção de ${formatarValor(projetado.valor, '%')} em ${formatarData(projetado.momento)} '
          '(hoje: ${formatarValor(atual.valor, '%')}).',
      evidencias: [
        'Volume em ${formatarData(atual.momento)}: ${formatarValor(atual.valor, '%')}.',
        'Tendência dos últimos $janela dias: $sinal${formatarNumero(reta.inclinacao, casas: 2)} ponto percentual por dia.',
        'Projeção para ${formatarData(projetado.momento)}: ${formatarValor(projetado.valor, '%')} '
            '(limite de ${nivel.rotulo}: ${formatarValor(limiar.valorDo(nivel), '%', casas: 0)}).',
        'Qualidade do ajuste da reta (R²): ${formatarNumero(reta.r2, casas: 2)} (1 = reta perfeita).',
      ],
      confianca: confianca,
      limitacoes: [
        'Projeção linear: não antecipa uma sequência de chuvas fortes nem uma estiagem que começa agora.',
        'A operação da Sabesp (transferências entre sistemas, redução de pressão) muda o volume de formas '
            'que a reta não enxerga.',
        'Dados públicos atualizados até ${formatarData(atual.momento)}'
            '${diasDeAtraso > 15 ? ' (mais de 15 dias atrás)' : ''}.',
      ],
      valorPrevisto: min(atual.valor, projetado.valor),
      limite: limiar.valorDo(nivel),
      unidade: '%',
      geradoEm: agora,
      eventoPrevistoEm: cruzamento,
    );
  }

  static Indicador? _porId(List<Indicador> lista, String id) {
    for (final i in lista) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// O mesmo alerta, na mesma hora, sempre tem o mesmo id (para lembrar se já foi avaliado).
  static String _id(String tipo, String indicadorId, NivelAlerta nivel, DateTime momento) =>
      '$tipo-$indicadorId-${nivel.name}-${momento.year}${momento.month}${momento.day}${momento.hour}';
}

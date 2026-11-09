import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

import '../core/utils/formatadores.dart';
import '../dados/fontes/armazenamento_local.dart';
import '../dados/fontes/clima_api.dart';
import '../dados/fontes/corregos_simulados.dart';
import '../dados/fontes/reservatorios_local.dart';
import '../dados/modelos/alerta.dart';
import '../dados/modelos/indicador.dart';
import '../dados/modelos/nivel_alerta.dart';
import '../logica/cenario_demonstracao.dart';
import '../logica/motor_alertas.dart';
import 'preferencias_provider.dart';

enum StatusCarga { inicial, carregando, pronto, erro }

/// ESTADO GLOBAL dos dados do território: os 3 painéis + os alertas.
/// Várias telas leem daqui (Início, painéis, detalhes, Alertas).
class TerritorioProvider extends ChangeNotifier {
  TerritorioProvider({
    required PreferenciasProvider preferencias,
    required ArmazenamentoLocal armazenamento,
    ClimaApi? climaApi,
    ReservatoriosLocal reservatoriosLocal = const ReservatoriosLocal(),
    MotorAlertas motor = const MotorAlertas(),
  })  : _preferencias = preferencias,
        _armazenamento = armazenamento,
        _climaApi = climaApi ?? ClimaApi(),
        _reservatoriosLocal = reservatoriosLocal,
        _motor = motor;

  final PreferenciasProvider _preferencias;
  final ArmazenamentoLocal _armazenamento;
  final ClimaApi _climaApi;
  final ReservatoriosLocal _reservatoriosLocal;
  final MotorAlertas _motor;

  static const _arquivoClimaExemplo = 'assets/dados/clima_exemplo.json';

  StatusCarga _status = StatusCarga.inicial;
  String? _mensagemErro;
  OrigemDados? _origemClima;
  DateTime? _climaObtidoEm;
  DateTime _agora = DateTime.now();
  bool _cenarioDemonstracao = false;
  ContextoDados _contextoClima = const ContextoDados();

  List<Indicador> _clima = [];
  List<Indicador> _corregos = [];
  List<Indicador> _reservatorios = [];
  List<Alerta> _alertas = [];

  StatusCarga get status => _status;
  String? get mensagemErro => _mensagemErro;
  OrigemDados? get origemClima => _origemClima;
  DateTime? get climaObtidoEm => _climaObtidoEm;
  DateTime get agora => _agora;
  bool get cenarioDemonstracao => _cenarioDemonstracao;
  bool get usandoDadosOffline => _origemClima != null && _origemClima != OrigemDados.api;

  /// true quando há dados para mostrar (mesmo que esteja recarregando por cima).
  bool get temDados => _clima.isNotEmpty || _reservatorios.isNotEmpty;

  List<Indicador> get clima => _clima;
  List<Indicador> get corregos => _corregos;
  List<Indicador> get reservatorios => _reservatorios;
  List<Alerta> get alertas => _alertas;

  // ------------------------------------------------------------------ consultas
  Indicador? indicadorPorId(String id) {
    for (final i in [..._clima, ..._corregos, ..._reservatorios]) {
      if (i.id == id) return i;
    }
    return null;
  }

  Alerta? alertaPorId(String id) {
    for (final a in _alertas) {
      if (a.id == id) return a;
    }
    return null;
  }

  List<Alerta> alertasDe(Dominio dominio) => _alertas.where((a) => a.dominio == dominio).toList();

  List<Alerta> alertasDoIndicador(String indicadorId) =>
      _alertas.where((a) => a.indicadorId == indicadorId).toList();

  /// Nível mais grave entre os alertas de um painel (NORMAL se não houver alerta).
  NivelAlerta nivelMaximo(Dominio dominio) {
    var maior = NivelAlerta.normal;
    for (final a in alertasDe(dominio)) {
      if (a.nivel.gravidade > maior.gravidade) maior = a.nivel;
    }
    return maior;
  }

  // ------------------------------------------------------------------ resumos para os cartões
  /// Soma da chuva das próximas 24 h ([futura] = true) ou das últimas 24 h.
  double somaChuva24h({required bool futura}) {
    final chuva = indicadorPorId('clima-chuva');
    if (chuva == null) return 0;
    final pontos = futura
        ? chuva.previsao.where((p) => !p.momento.isAfter(_agora.add(const Duration(hours: 24))))
        : chuva.historico.where((p) => p.momento.isAfter(_agora.subtract(const Duration(hours: 24))));
    return pontos.fold(0.0, (total, p) => total + p.valor);
  }

  /// Córrego com o maior nível medido agora.
  Indicador? get corregoMaisAlto {
    Indicador? maior;
    for (final c in _corregos) {
      if (maior == null || (c.valorAtual ?? 0) > (maior.valorAtual ?? 0)) maior = c;
    }
    return maior;
  }

  // ------------------------------------------------------------------ impacto social
  /// Pessoas que moram perto dos córregos monitorados (estimativa ilustrativa).
  int get pessoasEmAreasMonitoradas =>
      CorregosSimulados.corregos.fold(0, (total, c) => total + c.populacaoEstimada);

  /// Pessoas perto de córregos com alerta de ALERTA ou CRÍTICO agora.
  int get pessoasEmAreasComAlerta {
    var total = 0;
    for (final c in CorregosSimulados.corregos) {
      final emAlerta = alertasDoIndicador(c.id).any((a) => a.nivel.gravidade >= NivelAlerta.alerta.gravidade);
      if (emAlerta) total += c.populacaoEstimada;
    }
    return total;
  }

  /// Média de horas de antecedência dos alertas de chuva e córregos (null se não houver).
  double? get antecedenciaMediaHoras {
    final horas = _alertas
        .where((a) => a.dominio != Dominio.reservatorios)
        .map((a) => a.antecedenciaHoras)
        .whereType<double>()
        .toList();
    if (horas.isEmpty) return null;
    return horas.reduce((a, b) => a + b) / horas.length;
  }

  // ------------------------------------------------------------------ carga
  /// Busca tudo de novo. Ordem do clima: API -> cache do aparelho -> dados de exemplo.
  Future<void> carregar() async {
    if (_status == StatusCarga.carregando) return;
    _status = StatusCarga.carregando;
    _mensagemErro = null;
    notifyListeners();

    try {
      if (_preferencias.simularErro) {
        throw const ClimaIndisponivelException(
            'Falha simulada pelo modo demonstração (desligue em Ajustes > Demonstração).');
      }
      _agora = DateTime.now();
      _cenarioDemonstracao = _preferencias.modoDemonstracao;

      var dadosClima = await _obterClima();
      if (_cenarioDemonstracao) dadosClima = CenarioDemonstracao.tempestade(dadosClima, _agora);

      var reservatorios = await _reservatoriosLocal.carregar();
      if (_cenarioDemonstracao) reservatorios = CenarioDemonstracao.estiagem(reservatorios);

      _origemClima = dadosClima.origem;
      _climaObtidoEm = dadosClima.obtidoEm;
      _contextoClima = _montarContexto(dadosClima);
      _clima = dadosClima.paraIndicadores(_agora);
      _corregos = const CorregosSimulados().gerar(dadosClima.chuva, _agora);
      _reservatorios = reservatorios;
      _gerarAlertas();
      _status = StatusCarga.pronto;
    } catch (erro) {
      // limpa os dados para a tela mostrar o estado de erro com o botão "Tentar novamente"
      _clima = [];
      _corregos = [];
      _reservatorios = [];
      _alertas = [];
      _origemClima = null;
      _status = StatusCarga.erro;
      _mensagemErro = erro is ClimaIndisponivelException
          ? erro.mensagem
          : 'Não foi possível carregar os dados do território. Tente novamente.';
    }
    notifyListeners();
  }

  /// Refaz só os alertas (ex.: depois de mudar os limiares), sem buscar dados de novo.
  void recalcularAlertas() {
    if (_status != StatusCarga.pronto) return;
    _gerarAlertas();
    notifyListeners();
  }

  void _gerarAlertas() {
    _alertas = _motor.gerarTodos(
      clima: _clima,
      corregos: _corregos,
      reservatorios: _reservatorios,
      limiares: _preferencias.limiares,
      agora: _agora,
      contextoClima: _contextoClima,
    );
  }

  Future<ClimaDados> _obterClima() async {
    // 1) API ao vivo
    if (!_preferencias.simularSemConexao) {
      try {
        final corpo = await _climaApi.buscar();
        final dados = ClimaDados.deOpenMeteo(jsonDecode(corpo) as Map<String, dynamic>,
            origem: OrigemDados.api, obtidoEm: _agora);
        await _armazenamento.salvarCacheClima(corpo, _agora);
        return dados;
      } catch (_) {
        // sem internet, API fora do ar ou resposta estranha: segue para o cache
      }
    }

    // 2) cache salvo da última vez que deu certo
    final cache = _armazenamento.lerCacheClima();
    if (cache != null) {
      return ClimaDados.deOpenMeteo(jsonDecode(cache.corpo) as Map<String, dynamic>,
          origem: OrigemDados.cache, obtidoEm: cache.salvoEm);
    }

    // 3) dados de exemplo empacotados no app, "trazidos" para a data de hoje
    final json = jsonDecode(await rootBundle.loadString(_arquivoClimaExemplo)) as Map<String, dynamic>;
    final tempos = ((json['hourly'] as Map<String, dynamic>)['time'] as List).cast<String>();
    final horaAtual = DateTime(_agora.year, _agora.month, _agora.day, _agora.hour);
    final deslocamento = horaAtual.difference(DateTime.parse(tempos[48])); // posição 48 = "agora" no arquivo
    return ClimaDados.deOpenMeteo(json, origem: OrigemDados.exemplo, obtidoEm: _agora, deslocamento: deslocamento);
  }

  ContextoDados _montarContexto(ClimaDados dados) {
    final observacoes = <String>[];
    var fator = 1.0;
    switch (dados.origem) {
      case OrigemDados.api:
        break;
      case OrigemDados.cache:
        final idade = _agora.difference(dados.obtidoEm);
        fator = idade.inHours < 3
            ? 0.95
            : idade.inHours < 12
                ? 0.8
                : 0.6;
        observacoes.add('Sem conexão: usando a previsão salva ${formatarIdade(idade)}.');
      case OrigemDados.exemplo:
        fator = 0.4;
        observacoes.add('Sem conexão e sem dados salvos: usando DADOS DE EXEMPLO, que não representam o tempo de hoje.');
    }
    if (_cenarioDemonstracao) {
      observacoes.add('MODO DEMONSTRAÇÃO ligado: a tempestade é fictícia.');
    }
    return ContextoDados(fatorConfianca: fator, observacoes: observacoes);
  }
}

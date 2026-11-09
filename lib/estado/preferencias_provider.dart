import 'package:flutter/material.dart';

import '../dados/fontes/armazenamento_local.dart';
import '../dados/modelos/limiares.dart';

/// ESTADO GLOBAL das preferências da pessoa: tema, acessibilidade, consentimento,
/// limiares de alerta e chaves do modo demonstração. Tudo é salvo no aparelho.
class PreferenciasProvider extends ChangeNotifier {
  PreferenciasProvider(ArmazenamentoLocal armazenamento)
      : _armazenamento = armazenamento,
        _consentiu = armazenamento.consentiu,
        _tema = armazenamento.tema,
        _altoContraste = armazenamento.altoContraste,
        _escalaFonte = armazenamento.escalaFonte,
        _modoDemonstracao = armazenamento.modoDemonstracao,
        _simularSemConexao = armazenamento.simularSemConexao,
        _simularErro = armazenamento.simularErro,
        _limiares = armazenamento.lerLimiares(),
        _alertasAvaliados = armazenamento.alertasAvaliados;

  final ArmazenamentoLocal _armazenamento;

  bool _consentiu;
  String _tema;
  bool _altoContraste;
  double _escalaFonte;
  bool _modoDemonstracao;
  bool _simularSemConexao;
  bool _simularErro;
  Limiares _limiares;
  Set<String> _alertasAvaliados;

  bool get consentiu => _consentiu;
  bool get altoContraste => _altoContraste;
  double get escalaFonte => _escalaFonte;
  bool get modoDemonstracao => _modoDemonstracao;
  bool get simularSemConexao => _simularSemConexao;
  bool get simularErro => _simularErro;
  Limiares get limiares => _limiares;

  ThemeMode get modoTema => switch (_tema) {
        'claro' => ThemeMode.light,
        'escuro' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> definirConsentimento(bool valor) async {
    _consentiu = valor;
    notifyListeners();
    await _armazenamento.salvarConsentimento(valor);
  }

  Future<void> definirTema(ThemeMode modo) async {
    _tema = switch (modo) {
      ThemeMode.light => 'claro',
      ThemeMode.dark => 'escuro',
      ThemeMode.system => 'sistema',
    };
    notifyListeners();
    await _armazenamento.salvarTema(_tema);
  }

  Future<void> definirAltoContraste(bool valor) async {
    _altoContraste = valor;
    notifyListeners();
    await _armazenamento.salvarAltoContraste(valor);
  }

  Future<void> definirEscalaFonte(double valor) async {
    _escalaFonte = valor;
    notifyListeners();
    await _armazenamento.salvarEscalaFonte(valor);
  }

  Future<void> definirModoDemonstracao(bool valor) async {
    _modoDemonstracao = valor;
    notifyListeners();
    await _armazenamento.salvarModoDemonstracao(valor);
  }

  Future<void> definirSimularSemConexao(bool valor) async {
    _simularSemConexao = valor;
    notifyListeners();
    await _armazenamento.salvarSimularSemConexao(valor);
  }

  Future<void> definirSimularErro(bool valor) async {
    _simularErro = valor;
    notifyListeners();
    await _armazenamento.salvarSimularErro(valor);
  }

  Future<void> salvarLimiares(Limiares novos) async {
    _limiares = novos;
    notifyListeners();
    await _armazenamento.salvarLimiares(novos);
  }

  // ---------- "decisão humana": a pessoa marca que avaliou o alerta ----------
  bool foiAvaliado(String alertaId) => _alertasAvaliados.contains(alertaId);

  Future<void> alternarAvaliado(String alertaId) async {
    _alertasAvaliados = {..._alertasAvaliados};
    if (!_alertasAvaliados.remove(alertaId)) _alertasAvaliados.add(alertaId);
    notifyListeners();
    await _armazenamento.salvarAlertasAvaliados(_alertasAvaliados);
  }

  /// Apaga ocorrências, avaliações e consentimento (o app volta à tela de consentimento).
  Future<void> apagarDadosPessoais() async {
    await _armazenamento.apagarDadosPessoais();
    _alertasAvaliados = {};
    _consentiu = false;
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/limiares.dart';
import '../modelos/ocorrencia.dart';

/// ÚNICO lugar que lê e escreve no armazenamento do aparelho (shared_preferences).
/// O resto do app não sabe os nomes das chaves nem o formato salvo.
class ArmazenamentoLocal {
  ArmazenamentoLocal(this._prefs);

  final SharedPreferences _prefs;

  static const _consentimento = 'consentimento_v1';
  static const _tema = 'tema';
  static const _altoContraste = 'alto_contraste';
  static const _escalaFonte = 'escala_fonte';
  static const _modoDemonstracao = 'modo_demonstracao';
  static const _simularSemConexao = 'simular_sem_conexao';
  static const _simularErro = 'simular_erro';
  static const _limiares = 'limiares';
  static const _ocorrencias = 'ocorrencias';
  static const _alertasAvaliados = 'alertas_avaliados';
  static const _cacheClima = 'cache_clima';
  static const _cacheClimaEm = 'cache_clima_em';

  // ---------- preferências ----------
  bool get consentiu => _prefs.getBool(_consentimento) ?? false;
  Future<void> salvarConsentimento(bool valor) => _prefs.setBool(_consentimento, valor);

  String get tema => _prefs.getString(_tema) ?? 'sistema';
  Future<void> salvarTema(String valor) => _prefs.setString(_tema, valor);

  bool get altoContraste => _prefs.getBool(_altoContraste) ?? false;
  Future<void> salvarAltoContraste(bool valor) => _prefs.setBool(_altoContraste, valor);

  double get escalaFonte => _prefs.getDouble(_escalaFonte) ?? 1.0;
  Future<void> salvarEscalaFonte(double valor) => _prefs.setDouble(_escalaFonte, valor);

  bool get modoDemonstracao => _prefs.getBool(_modoDemonstracao) ?? false;
  Future<void> salvarModoDemonstracao(bool valor) => _prefs.setBool(_modoDemonstracao, valor);

  bool get simularSemConexao => _prefs.getBool(_simularSemConexao) ?? false;
  Future<void> salvarSimularSemConexao(bool valor) => _prefs.setBool(_simularSemConexao, valor);

  bool get simularErro => _prefs.getBool(_simularErro) ?? false;
  Future<void> salvarSimularErro(bool valor) => _prefs.setBool(_simularErro, valor);

  // ---------- limiares ----------
  Limiares lerLimiares() {
    final texto = _prefs.getString(_limiares);
    if (texto == null) return Limiares.padrao;
    try {
      return Limiares.fromJson(jsonDecode(texto) as Map<String, dynamic>);
    } catch (_) {
      // dado salvo corrompido ou de uma versão antiga: volta aos padrões
      return Limiares.padrao;
    }
  }

  Future<void> salvarLimiares(Limiares limiares) => _prefs.setString(_limiares, jsonEncode(limiares.toJson()));

  // ---------- ocorrências ----------
  List<Ocorrencia> lerOcorrencias() {
    final texto = _prefs.getString(_ocorrencias);
    if (texto == null) return [];
    try {
      final lista = (jsonDecode(texto) as List).cast<Map<String, dynamic>>();
      return lista.map(Ocorrencia.fromJson).toList();
    } catch (_) {
      // se o formato mudou entre versões, começa uma lista nova em vez de travar o app
      return [];
    }
  }

  Future<void> salvarOcorrencias(List<Ocorrencia> ocorrencias) =>
      _prefs.setString(_ocorrencias, jsonEncode(ocorrencias.map((o) => o.toJson()).toList()));

  // ---------- alertas avaliados por uma pessoa ----------
  Set<String> get alertasAvaliados => (_prefs.getStringList(_alertasAvaliados) ?? const []).toSet();
  Future<void> salvarAlertasAvaliados(Set<String> ids) => _prefs.setStringList(_alertasAvaliados, ids.toList());

  // ---------- cache da API de clima ----------
  ({String corpo, DateTime salvoEm})? lerCacheClima() {
    final corpo = _prefs.getString(_cacheClima);
    final em = _prefs.getString(_cacheClimaEm);
    if (corpo == null || em == null) return null;
    return (corpo: corpo, salvoEm: DateTime.parse(em));
  }

  Future<void> salvarCacheClima(String corpo, DateTime salvoEm) async {
    await _prefs.setString(_cacheClima, corpo);
    await _prefs.setString(_cacheClimaEm, salvoEm.toIso8601String());
  }

  /// Direito de apagar: remove tudo o que a pessoa registrou e o consentimento.
  Future<void> apagarDadosPessoais() async {
    await _prefs.remove(_ocorrencias);
    await _prefs.remove(_alertasAvaliados);
    await _prefs.remove(_consentimento);
  }
}

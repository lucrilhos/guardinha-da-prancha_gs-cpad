import 'package:flutter/foundation.dart';

import '../dados/fontes/armazenamento_local.dart';
import '../dados/modelos/ocorrencia.dart';
import '../logica/anonimizador.dart';

/// ESTADO GLOBAL das ocorrências registradas pelo cidadão (lista + gravação no aparelho).
class OcorrenciasProvider extends ChangeNotifier {
  OcorrenciasProvider(ArmazenamentoLocal armazenamento)
      : _armazenamento = armazenamento,
        _ocorrencias = armazenamento.lerOcorrencias();

  final ArmazenamentoLocal _armazenamento;
  final List<Ocorrencia> _ocorrencias;

  /// Mais recentes primeiro. Lista só de leitura: quem quiser mudar usa os métodos abaixo.
  List<Ocorrencia> get ocorrencias {
    final copia = [..._ocorrencias]..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
    return List.unmodifiable(copia);
  }

  int get total => _ocorrencias.length;

  /// Anonimiza a descrição ANTES de guardar e devolve o que foi removido (para avisar a pessoa).
  Future<ResultadoAnonimizacao> registrar({
    required TipoOcorrencia tipo,
    required String regiao,
    required String descricao,
    required int gravidade,
  }) async {
    final anonimo = Anonimizador.anonimizar(descricao.trim());
    _ocorrencias.add(Ocorrencia(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // id aleatório: não identifica a pessoa
      tipo: tipo,
      regiao: regiao,
      descricao: anonimo.texto,
      gravidade: gravidade,
      criadaEm: DateTime.now(),
    ));
    notifyListeners();
    await _armazenamento.salvarOcorrencias(_ocorrencias);
    return anonimo;
  }

  Future<void> remover(String id) async {
    _ocorrencias.removeWhere((o) => o.id == id);
    notifyListeners();
    await _armazenamento.salvarOcorrencias(_ocorrencias);
  }

  /// Chamado depois de "Apagar meus dados" (o armazenamento já foi limpo).
  void esvaziar() {
    _ocorrencias.clear();
    notifyListeners();
  }
}

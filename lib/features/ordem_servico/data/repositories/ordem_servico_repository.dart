import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ordem_servico_entity.dart';
import '../models/ordem_servico_model.dart';

class OrdemServicoRepository {
  final _col = FirebaseFirestore.instance.collection('ordens_servico');

  Stream<List<OrdemServicoEntity>> listar() {
    return _col
        .orderBy('dataAbertura', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrdemServicoModel.fromFirestore(d)).toList());
  }

  Future<void> salvar(OrdemServicoModel model) async {
    if (model.id.isEmpty) {
      await _col.add(model.toFirestore());
    } else {
      await _col.doc(model.id).update(model.toFirestore());
    }
  }

  Future<void> atualizarStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }

  Future<void> encerrar({
    required String id,
    required String descricaoSolucao,
    required String tecnicoResponsavel,
  }) async {
    await _col.doc(id).update({
      'status': 'concluida',
      'descricaoSolucao': descricaoSolucao,
      'tecnicoResponsavel': tecnicoResponsavel,
      'dataEncerramento': Timestamp.fromDate(DateTime.now()),
    });
  }
}

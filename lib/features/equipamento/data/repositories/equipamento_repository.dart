import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/equipamento_entity.dart';
import '../models/equipamento_model.dart';

class EquipamentoRepository {
  final _col = FirebaseFirestore.instance.collection('equipamentos');

  Stream<List<EquipamentoEntity>> listar() {
    return _col
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => EquipamentoModel.fromFirestore(d)).toList());
  }

  Future<void> salvar(EquipamentoModel model) async {
    if (model.id.isEmpty) {
      await _col.add(model.toFirestore());
    } else {
      await _col.doc(model.id).update(model.toFirestore());
    }
  }

  Future<void> excluir(String id) async {
    await _col.doc(id).update({'ativo': false});
  }
}

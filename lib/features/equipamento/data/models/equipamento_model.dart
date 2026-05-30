import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/equipamento_entity.dart';

class EquipamentoModel extends EquipamentoEntity {
  const EquipamentoModel({
    required super.id,
    required super.nome,
    required super.marca,
    required super.modelo,
    required super.ntagPatrimonio,
    required super.setor,
    required super.criticidade,
    super.ultimaManutencao,
    super.ativo,
  });

  factory EquipamentoModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EquipamentoModel(
      id: doc.id,
      nome: d['nome'] ?? '',
      marca: d['marca'] ?? '',
      modelo: d['modelo'] ?? '',
      ntagPatrimonio: d['ntagPatrimonio'] ?? '',
      setor: SetorHospital.values.firstWhere((e) => e.name == d['setor'], orElse: () => SetorHospital.outros),
      criticidade: Criticidade.values.firstWhere((e) => e.name == d['criticidade'], orElse: () => Criticidade.baixa),
      ultimaManutencao: (d['ultimaManutencao'] as Timestamp?)?.toDate(),
      ativo: d['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'nome': nome,
    'marca': marca,
    'modelo': modelo,
    'ntagPatrimonio': ntagPatrimonio,
    'setor': setor.name,
    'criticidade': criticidade.name,
    'ultimaManutencao': ultimaManutencao != null ? Timestamp.fromDate(ultimaManutencao!) : null,
    'ativo': ativo,
  };
}

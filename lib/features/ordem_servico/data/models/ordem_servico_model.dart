import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/ordem_servico_entity.dart';
import '../../../equipamento/domain/entities/equipamento_entity.dart';

class OrdemServicoModel extends OrdemServicoEntity {
  const OrdemServicoModel({
    required super.id,
    required super.numero,
    required super.equipamento,
    required super.tipoManutencao,
    required super.criticidade,
    required super.status,
    required super.descricaoProblema,
    required super.solicitante,
    required super.dataAbertura,
    super.descricaoSolucao,
    super.tecnicoResponsavel,
    super.dataEncerramento,
  });

  factory OrdemServicoModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    // Equipamento inline (sem join)
    final eqData = d['equipamento'] as Map<String, dynamic>? ?? {};
    final eq = _EquipamentoInline(
      id: eqData['id'] ?? '',
      nome: eqData['nome'] ?? '',
      marca: eqData['marca'] ?? '',
      modelo: eqData['modelo'] ?? '',
      ntagPatrimonio: eqData['ntag'] ?? '',
      setor: SetorHospital.values.firstWhere((e) => e.name == eqData['setor'], orElse: () => SetorHospital.outros),
      criticidade: Criticidade.values.firstWhere((e) => e.name == eqData['criticidade'], orElse: () => Criticidade.baixa),
    );
    return OrdemServicoModel(
      id: doc.id,
      numero: d['numero'] ?? '',
      equipamento: eq,
      tipoManutencao: TipoManutencao.values.firstWhere((e) => e.name == d['tipoManutencao'], orElse: () => TipoManutencao.corretiva),
      criticidade: Criticidade.values.firstWhere((e) => e.name == d['criticidade'], orElse: () => Criticidade.baixa),
      status: StatusOS.values.firstWhere((e) => e.name == d['status'], orElse: () => StatusOS.aberta),
      descricaoProblema: d['descricaoProblema'] ?? '',
      descricaoSolucao: d['descricaoSolucao'],
      solicitante: d['solicitante'] ?? '',
      tecnicoResponsavel: d['tecnicoResponsavel'],
      dataAbertura: (d['dataAbertura'] as Timestamp).toDate(),
      dataEncerramento: (d['dataEncerramento'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'numero': numero,
    'equipamento': {
      'id': equipamento.id,
      'nome': equipamento.nome,
      'marca': equipamento.marca,
      'modelo': equipamento.modelo,
      'ntag': equipamento.ntagPatrimonio,
      'setor': equipamento.setor.name,
      'criticidade': equipamento.criticidade.name,
    },
    'tipoManutencao': tipoManutencao.name,
    'criticidade': criticidade.name,
    'status': status.name,
    'descricaoProblema': descricaoProblema,
    'descricaoSolucao': descricaoSolucao,
    'solicitante': solicitante,
    'tecnicoResponsavel': tecnicoResponsavel,
    'dataAbertura': Timestamp.fromDate(dataAbertura),
    'dataEncerramento': dataEncerramento != null ? Timestamp.fromDate(dataEncerramento!) : null,
  };
}

class _EquipamentoInline extends EquipamentoEntity {
  const _EquipamentoInline({
    required super.id,
    required super.nome,
    required super.marca,
    required super.modelo,
    required super.ntagPatrimonio,
    required super.setor,
    required super.criticidade,
  });
}

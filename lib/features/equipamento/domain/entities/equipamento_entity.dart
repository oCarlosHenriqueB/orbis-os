import '../../../../core/enums/app_enums.dart';

class EquipamentoEntity {
  final String id;
  final String nome;
  final String marca;
  final String modelo;
  final String ntagPatrimonio;
  final SetorHospital setor;
  final Criticidade criticidade;
  final DateTime? ultimaManutencao;
  final bool ativo;

  const EquipamentoEntity({
    required this.id,
    required this.nome,
    required this.marca,
    required this.modelo,
    required this.ntagPatrimonio,
    required this.setor,
    required this.criticidade,
    this.ultimaManutencao,
    this.ativo = true,
  });
}

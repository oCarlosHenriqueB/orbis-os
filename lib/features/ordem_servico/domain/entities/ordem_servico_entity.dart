import '../../../../core/enums/app_enums.dart';
import '../../../equipamento/domain/entities/equipamento_entity.dart';

class OrdemServicoEntity {
  final String id;
  final String numero;
  final EquipamentoEntity equipamento;
  final TipoManutencao tipoManutencao;
  final Criticidade criticidade;
  final StatusOS status;
  final String descricaoProblema;
  final String? descricaoSolucao;
  final String solicitante;
  final String? tecnicoResponsavel;
  final DateTime dataAbertura;
  final DateTime? dataEncerramento;

  const OrdemServicoEntity({
    required this.id,
    required this.numero,
    required this.equipamento,
    required this.tipoManutencao,
    required this.criticidade,
    required this.status,
    required this.descricaoProblema,
    required this.solicitante,
    required this.dataAbertura,
    this.descricaoSolucao,
    this.tecnicoResponsavel,
    this.dataEncerramento,
  });
}

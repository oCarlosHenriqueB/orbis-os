part of 'os_bloc.dart';

abstract class OsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OsStarted extends OsEvent {}

class OsListLoaded extends OsEvent {
  final List<OrdemServicoEntity> ordens;
  OsListLoaded(this.ordens);
  @override
  List<Object?> get props => [ordens];
}

class OsSalvar extends OsEvent {
  final OrdemServicoModel model;
  OsSalvar(this.model);
  @override
  List<Object?> get props => [model];
}

class OsAtualizarStatus extends OsEvent {
  final String id;
  final String status;
  OsAtualizarStatus({required this.id, required this.status});
  @override
  List<Object?> get props => [id, status];
}

class OsEncerrar extends OsEvent {
  final String id;
  final String descricaoSolucao;
  final String tecnicoResponsavel;
  OsEncerrar({required this.id, required this.descricaoSolucao, required this.tecnicoResponsavel});
  @override
  List<Object?> get props => [id, descricaoSolucao, tecnicoResponsavel];
}

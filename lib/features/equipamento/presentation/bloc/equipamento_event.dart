part of 'equipamento_bloc.dart';

abstract class EquipamentoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EquipamentoStarted extends EquipamentoEvent {}

class EquipamentoLoaded extends EquipamentoEvent {
  final List<EquipamentoEntity> equipamentos;
  EquipamentoLoaded(this.equipamentos);
  @override
  List<Object?> get props => [equipamentos];
}

class EquipamentoSalvar extends EquipamentoEvent {
  final EquipamentoModel model;
  EquipamentoSalvar(this.model);
  @override
  List<Object?> get props => [model];
}

class EquipamentoExcluir extends EquipamentoEvent {
  final String id;
  EquipamentoExcluir(this.id);
  @override
  List<Object?> get props => [id];
}

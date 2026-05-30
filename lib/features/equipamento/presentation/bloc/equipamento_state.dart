part of 'equipamento_bloc.dart';

abstract class EquipamentoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EquipamentoInitial extends EquipamentoState {}
class EquipamentoLoading extends EquipamentoState {}

class EquipamentoSuccess extends EquipamentoState {
  final List<EquipamentoEntity> equipamentos;
  EquipamentoSuccess(this.equipamentos);
  @override
  List<Object?> get props => [equipamentos];
}

class EquipamentoError extends EquipamentoState {
  final String message;
  EquipamentoError(this.message);
  @override
  List<Object?> get props => [message];
}

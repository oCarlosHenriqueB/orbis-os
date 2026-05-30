part of 'os_bloc.dart';

abstract class OsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OsInitial extends OsState {}
class OsLoading extends OsState {}

class OsSuccess extends OsState {
  final List<OrdemServicoEntity> ordens;
  OsSuccess(this.ordens);
  @override
  List<Object?> get props => [ordens];
}

class OsError extends OsState {
  final String message;
  OsError(this.message);
  @override
  List<Object?> get props => [message];
}

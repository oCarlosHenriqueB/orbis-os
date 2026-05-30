import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/ordem_servico_model.dart';
import '../../data/repositories/ordem_servico_repository.dart';
import '../../domain/entities/ordem_servico_entity.dart';

part 'os_event.dart';
part 'os_state.dart';

class OsBloc extends Bloc<OsEvent, OsState> {
  final _repo = OrdemServicoRepository();
  StreamSubscription? _sub;

  OsBloc() : super(OsInitial()) {
    on<OsStarted>(_onStarted);
    on<OsListLoaded>(_onLoaded);
    on<OsSalvar>(_onSalvar);
    on<OsAtualizarStatus>(_onAtualizarStatus);
    on<OsEncerrar>(_onEncerrar);
  }

  void _onStarted(OsStarted event, Emitter<OsState> emit) {
    emit(OsLoading());
    _sub?.cancel();
    _sub = _repo.listar().listen(
      (list) => add(OsListLoaded(list)),
      onError: (e) => emit(OsError(e.toString())),
    );
  }

  void _onLoaded(OsListLoaded event, Emitter<OsState> emit) {
    emit(OsSuccess(event.ordens));
  }

  Future<void> _onSalvar(OsSalvar event, Emitter<OsState> emit) async {
    try {
      await _repo.salvar(event.model);
    } catch (e) {
      emit(OsError(e.toString()));
    }
  }

  Future<void> _onAtualizarStatus(OsAtualizarStatus event, Emitter<OsState> emit) async {
    try {
      await _repo.atualizarStatus(event.id, event.status);
    } catch (e) {
      emit(OsError(e.toString()));
    }
  }

  Future<void> _onEncerrar(OsEncerrar event, Emitter<OsState> emit) async {
    try {
      await _repo.encerrar(
        id: event.id,
        descricaoSolucao: event.descricaoSolucao,
        tecnicoResponsavel: event.tecnicoResponsavel,
      );
    } catch (e) {
      emit(OsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

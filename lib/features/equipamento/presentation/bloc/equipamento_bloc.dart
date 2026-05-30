import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/equipamento_model.dart';
import '../../data/repositories/equipamento_repository.dart';
import '../../domain/entities/equipamento_entity.dart';

part 'equipamento_event.dart';
part 'equipamento_state.dart';

class EquipamentoBloc extends Bloc<EquipamentoEvent, EquipamentoState> {
  final _repo = EquipamentoRepository();
  StreamSubscription? _sub;

  EquipamentoBloc() : super(EquipamentoInitial()) {
    on<EquipamentoStarted>(_onStarted);
    on<EquipamentoLoaded>(_onLoaded);
    on<EquipamentoSalvar>(_onSalvar);
    on<EquipamentoExcluir>(_onExcluir);
  }

  void _onStarted(EquipamentoStarted event, Emitter<EquipamentoState> emit) {
    emit(EquipamentoLoading());
    _sub?.cancel();
    _sub = _repo.listar().listen(
      (list) => add(EquipamentoLoaded(list)),
      onError: (e) => emit(EquipamentoError(e.toString())),
    );
  }

  void _onLoaded(EquipamentoLoaded event, Emitter<EquipamentoState> emit) {
    emit(EquipamentoSuccess(event.equipamentos));
  }

  Future<void> _onSalvar(EquipamentoSalvar event, Emitter<EquipamentoState> emit) async {
    try {
      await _repo.salvar(event.model);
    } catch (e) {
      emit(EquipamentoError(e.toString()));
    }
  }

  Future<void> _onExcluir(EquipamentoExcluir event, Emitter<EquipamentoState> emit) async {
    try {
      await _repo.excluir(event.id);
    } catch (e) {
      emit(EquipamentoError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

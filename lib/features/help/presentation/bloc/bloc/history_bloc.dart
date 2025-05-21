import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maize_guard/features/help/domain/usecases/delete_history_usecase.dart';
import 'package:maize_guard/features/help/domain/usecases/get_history_usecase.dart';

import '../../../domain/entities/history_entities.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUsecase getHistoryUsecase;
  final DeleteHistoryUsecase deleteHistoryUsecase;
  List<HistoryModel> history = [];
  HistoryBloc({
    required this.getHistoryUsecase,
    required this.deleteHistoryUsecase,
  }) : super(HistoryInitial()) {
    on<GetHistoryEvent>((event, emit) async {
      emit(GetHistoryLoadingState());
      final result = await getHistoryUsecase();
      result.fold(
          (failure) => emit(
              GetHistoryErrorState(message: failure.message, history: history)),
          (history) {
        this.history = history;
        emit(GetHistorySuccessState(message: 'Success', history: this.history));
      });
    });

    on<DeleteHistoryEvent>((event, emit) async {
      emit(GetHistoryLoadingState());
      final result = await deleteHistoryUsecase(event.id);
      result.fold(
          (failure) => emit(
              GetHistoryErrorState(message: failure.message, history: history)),
          (message) {
        history.removeWhere((element) => element.id == event.id);
        emit(DeleteHistorySuccessState(
            message: "Deleted Successfully!", history: history));
      });
    });
  }
}

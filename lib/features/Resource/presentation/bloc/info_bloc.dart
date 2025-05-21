import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maize_guard/features/Resource/domain/entities/disease.dart';
import 'package:maize_guard/features/Resource/domain/usecases/get_info_usecase.dart';

part 'info_event.dart';
part 'info_state.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final GetInfoUsecase getInfoUsecase;
  List<Disease> info = [];
  InfoBloc({required this.getInfoUsecase}) : super(InfoInitial()) {
    on<GetInfoEvent>((event, emit) async {
      emit(InfoLoadingState());
      final result = await getInfoUsecase();
      result.fold((failure) => emit(InfoErrorState(message: failure.message)),
          (info) {
        this.info = info;
        emit(InfoSuccessState(message: 'Success', info: this.info));
      });
    });
  }
}

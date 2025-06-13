import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maize_guard/features/Resource/domain/entities/disease.dart';
import 'package:maize_guard/features/Resource/domain/usecases/delete_disease_usecase.dart';
import 'package:maize_guard/features/Resource/domain/usecases/get_info_usecase.dart';
import 'package:maize_guard/features/Resource/domain/usecases/update_disease_usecase.dart';

import '../../domain/usecases/add_disease_usecase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'info_event.dart';
part 'info_state.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final GetInfoUsecase getInfoUsecase;
  final DeleteDiseaseUsecase deleteDiseaseUsecase;
  final UpdateDiseaseUsecase updateDiseaseUsecase;
  final AddDiseaseUsecase addDiseaseUsecase;
  List<Disease> info = [];
  InfoBloc({
    required this.getInfoUsecase,
    required this.deleteDiseaseUsecase,
    required this.updateDiseaseUsecase,
    required this.addDiseaseUsecase,
  }) : super(InfoInitial()) {
    on<GetInfoEvent>((event, emit) async {
      emit(InfoLoadingState());
      final result = await getInfoUsecase();
      result.fold((failure) => emit(InfoErrorState(message: failure.message)),
          (info) {
        this.info = info;
        emit(InfoSuccessState(message: 'Success', info: this.info));
      });
    });
    on<AddDiseaseEvent>((event, emit) async {
      emit(InfoLoadingState());
      final result = await addDiseaseUsecase(event.disease);
      result.fold((failure) => emit(InfoErrorState(message: failure.message)),
          (disease) {
        info.insert(0, disease);
        emit(InfoSuccessState(
            message: 'Disease added successfully', info: info));
      });
    });
    on<UpdateDiseaseEvent>((event, emit) async {
      emit(InfoLoadingState());
      final result = await updateDiseaseUsecase(event.disease);
      result.fold((failure) => emit(InfoErrorState(message: failure.message)),
          (disease) {
        int index = info.indexWhere((d) => d.id == disease.id);
        if (index != -1) {
          info[index] = disease;
        }
        emit(InfoSuccessState(
            message: 'Disease updated successfully', info: info));
      });
    });
    on<DeleteDiseaseEvent>((event, emit) async {
      emit(InfoLoadingState());
      final result = await deleteDiseaseUsecase(event.id);
      result.fold((failure) => emit(InfoErrorState(message: failure.message)),
          (message) {
        info.removeWhere((disease) => disease.id == event.id);
        emit(InfoSuccessState(
            message: "Deleted disease successfully", info: info));
      });
    });
  }
}

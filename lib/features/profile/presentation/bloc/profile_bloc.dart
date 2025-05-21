import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maize_guard/features/profile/domain/usecases/update_profile_usecase.dart';

import '../../../auth/domain/entities/entity.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUsecase updateProfileUsecase;

  ProfileBloc({
    required this.updateProfileUsecase,
  }) : super(ProfileInitial()) {
    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileInitial());
      final result = await updateProfileUsecase(event.user);
      result.fold((l) => emit(UpdateFailureState(l.message)),
          (r) => emit(UpdateSuccessState()));
    });
  }
}

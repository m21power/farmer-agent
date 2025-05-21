import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';
import 'package:maize_guard/features/auth/domain/usecases/sign_up_usecase.dart';

import '../../domain/usecases/is_logged_in_usecase.dart';
import '../../domain/usecases/log_out_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final LogOutUsecase logOutUsecase;
  final IsLoggedInUsecase isLoggedInUsecase;
  final SignUpUsecase signUpUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.logOutUsecase,
    required this.isLoggedInUsecase,
    required this.signUpUsecase,
  }) : super(AuthInitial()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthInitial());
      final result = await loginUsecase(
        phone: event.phone,
        password: event.password,
      );
      result.fold(
        (failure) => emit(AuthLoginFailureState(message: failure.message)),
        (token) => emit(AuthLoginSuccessState(token: token)),
      );
    });

    on<AuthLogoutEvent>((event, emit) async {
      emit(AuthInitial());
      final result = await logOutUsecase();
      result.fold(
        (failure) => emit(AuthLogoutFailureState(message: failure.message)),
        (_) => emit(AuthLogoutSuccessState()),
      );
    });
    on<AuthCheckEvent>((event, emit) async {
      emit(AuthInitial());
      final result = await isLoggedInUsecase();
      result.fold(
        (failure) => emit(AuthCheckFailureState(message: failure.message)),
        (token) => emit(AuthCheckSuccessState(token: token)),
      );
    });
    on<AuthSignupEvent>((event, emit) async {
      emit(AuthInitial());
      final result = await signUpUsecase(event.user);
      result.fold(
        (failure) =>
            emit(AuthSignupFailureState(message: "${failure.message}")),
        (user) => emit(AuthSignupSuccessState(user: user)),
      );
    });
  }
}

part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoginSuccessState extends AuthState {
  final String token;

  const AuthLoginSuccessState({
    required this.token,
  });

  @override
  List<Object> get props => [token];
}

final class AuthLoginFailureState extends AuthState {
  final String message;

  const AuthLoginFailureState({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

final class AuthLogoutSuccessState extends AuthState {
  const AuthLogoutSuccessState();
}

final class AuthLogoutFailureState extends AuthState {
  final String message;

  const AuthLogoutFailureState({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

final class AuthCheckSuccessState extends AuthState {
  final String token;

  const AuthCheckSuccessState({
    required this.token,
  });

  @override
  List<Object> get props => [token];
}

final class AuthCheckFailureState extends AuthState {
  final String message;

  const AuthCheckFailureState({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

final class AuthSignupSuccessState extends AuthState {
  final User user;

  const AuthSignupSuccessState({
    required this.user,
  });

  @override
  List<Object> get props => [user];
}

final class AuthSignupFailureState extends AuthState {
  final String message;

  const AuthSignupFailureState({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

final class AuthRegisterSuccessState extends AuthState {
  final String message;

  const AuthRegisterSuccessState({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

final class AuthRegisterFailureState extends AuthState {
  final String message;

  const AuthRegisterFailureState({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

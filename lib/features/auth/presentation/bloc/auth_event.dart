part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginEvent extends AuthEvent {
  final String phone;
  final String password;

  const AuthLoginEvent({
    required this.phone,
    required this.password,
  });
}

final class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

final class AuthCheckEvent extends AuthEvent {
  const AuthCheckEvent();
}

final class AuthSignupEvent extends AuthEvent {
  final User user;
  const AuthSignupEvent({
    required this.user,
  });
}

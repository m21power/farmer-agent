import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

final class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase({
    required this.repository,
  });

  Future<Either<Failure, String>> call({
    required String phone,
    required String password,
  }) {
    return repository.login(
      phone: phone,
      password: password,
    );
  }
}

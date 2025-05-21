import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';

import '../repository/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository authRepository;

  SignUpUsecase({required this.authRepository});

  Future<Either<Failure, User>> call(User user) {
    return authRepository.register(user);
  }
}

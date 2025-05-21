import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class LogOutUsecase {
  final AuthRepository authRepository;

  LogOutUsecase({required this.authRepository});

  Future<Either<Failure, void>> call() {
    return authRepository.logOut();
  }
}

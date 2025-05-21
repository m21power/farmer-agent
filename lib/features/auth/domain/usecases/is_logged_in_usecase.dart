import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class IsLoggedInUsecase {
  final AuthRepository authRepository;
  IsLoggedInUsecase({required this.authRepository});
  Future<Either<Failure, String>> call() {
    return authRepository.isLoggedIn();
  }
}

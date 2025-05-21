import 'package:dartz/dartz.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';

import '../../../../core/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login({
    required String phone,
    required String password,
  });
  Future<Either<Failure, void>> logOut();
  Future<Either<Failure, String>> isLoggedIn();
  Future<Either<Failure, User>> register(User user);
}

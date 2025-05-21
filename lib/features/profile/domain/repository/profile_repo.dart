import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';

abstract class ProfileRepo {
  Future<Either<Failure, void>> updateProfile(User user);
}

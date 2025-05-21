import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';
import 'package:maize_guard/features/profile/domain/repository/profile_repo.dart';

class UpdateProfileUsecase {
  final ProfileRepo repository;
  UpdateProfileUsecase({
    required this.repository,
  });
  Future<Either<Failure, void>> call(User user) {
    return repository.updateProfile(user);
  }
}

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

class DeletePostUsecase {
  final CommunityRepo communityRepo;
  DeletePostUsecase({required this.communityRepo});
  Future<Either<Failure, void>> call(String questionId) {
    return communityRepo.deletePost(questionId);
  }
}

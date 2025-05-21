import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

class EditReplyUsecase {
  final CommunityRepo communityRepo;
  EditReplyUsecase({required this.communityRepo});
  Future<Either<Failure, void>> call(
      String questionId, String commentId, String reply) {
    return communityRepo.editReply(questionId, commentId, reply);
  }
}

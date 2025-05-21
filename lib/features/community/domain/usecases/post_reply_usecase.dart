import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

import '../entities/post_entities.dart';

class PostReplyUsecase {
  final CommunityRepo communityRepo;
  PostReplyUsecase({required this.communityRepo});
  Future<Either<Failure, ReplyModel>> call(String questionId, String reply) {
    return communityRepo.postReply(questionId, reply);
  }
}

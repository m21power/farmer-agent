import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

import '../entities/post_entities.dart';

class GetPostUsecase {
  final CommunityRepo communityRepo;
  GetPostUsecase({required this.communityRepo});
  Future<Either<Failure, List<PostModel>>> call() {
    return communityRepo.getPosts();
  }
}

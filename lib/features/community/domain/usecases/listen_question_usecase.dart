import '../entities/post_entities.dart';
import '../repository/community_repo.dart';

class ListenQuestionUsecase {
  final CommunityRepo communityRepo;
  ListenQuestionUsecase({required this.communityRepo});
  Stream<PostModel> call() {
    return communityRepo.questionStream();
  }
}

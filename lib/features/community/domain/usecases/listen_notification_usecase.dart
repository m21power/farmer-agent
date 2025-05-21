import '../entities/post_entities.dart';
import '../repository/community_repo.dart';

class ListenNotificationUsecase {
  final CommunityRepo communityRepo;
  ListenNotificationUsecase({required this.communityRepo});
  Stream<NotificationModel> call() {
    return communityRepo.notificationStream();
  }
}

import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

class SeenNotificationUsecase {
  final CommunityRepo communityRepo;
  SeenNotificationUsecase({required this.communityRepo});
  Future<void> call(String notificationId) {
    return communityRepo.seenNotification(notificationId);
  }
}

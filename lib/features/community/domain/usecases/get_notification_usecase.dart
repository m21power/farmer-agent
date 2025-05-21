import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/entities/post_entities.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

class GetNotificationUsecase {
  final CommunityRepo communityRepo;
  GetNotificationUsecase({required this.communityRepo});
  Future<Either<Failure, List<NotificationModel>>> call() {
    return communityRepo.getNotifications();
  }
}

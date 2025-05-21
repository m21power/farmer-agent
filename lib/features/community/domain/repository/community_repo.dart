import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/entities/post_entities.dart';

abstract class CommunityRepo {
  Future<Either<Failure, List<PostModel>>> getPosts();
  Future<Either<Failure, PostModel>> postQuestion(File? file, String question);
  Future<Either<Failure, ReplyModel>> postReply(
      String questionId, String reply);
  Future<Either<Failure, void>> deletePost(String questionId);
  Future<Either<Failure, void>> deleteReply(
      String questionId, String commentId);
  Future<Either<Failure, void>> editReply(
      String questionId, String commentId, String reply);
  Future<Either<Failure, void>> editPost(String questionId, String question);
  Future<void> seenNotification(String notificationId);

  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  Stream<NotificationModel> notificationStream();
  Stream<PostModel> questionStream();
}

part of 'community_bloc.dart';

sealed class CommunityEvent {
  const CommunityEvent();
}

final class GetPostsEvent extends CommunityEvent {
  const GetPostsEvent();
}

final class PostQuestionEvent extends CommunityEvent {
  const PostQuestionEvent({
    required this.question,
    required this.image,
  });

  final String question;
  final File? image;
}

final class ReplyQuestionEvent extends CommunityEvent {
  const ReplyQuestionEvent({
    required this.questionId,
    required this.reply,
  });

  final String questionId;
  final String reply;
}

final class GetNotificationEvent extends CommunityEvent {}

final class SeenNotificationEvent extends CommunityEvent {
  final String notificationId;
  SeenNotificationEvent({required this.notificationId});
}

final class CheckInternetEvent extends CommunityEvent {
  const CheckInternetEvent();
}

final class DeletePostEvent extends CommunityEvent {
  final String questionId;
  DeletePostEvent({required this.questionId});
}

final class UpdatePostEvent extends CommunityEvent {
  final String questionId;
  final String question;
  UpdatePostEvent({required this.questionId, required this.question});
}

final class EditReplyEvent extends CommunityEvent {
  final String questionId;
  final String commentId;
  final String reply;
  EditReplyEvent({
    required this.questionId,
    required this.commentId,
    required this.reply,
  });
}

final class DeleteReplyEvent extends CommunityEvent {
  final String questionId;
  final String commentId;
  DeleteReplyEvent({
    required this.questionId,
    required this.commentId,
  });
}

class RealTimeNotificationEvent extends CommunityEvent {
  final NotificationModel notification;

  RealTimeNotificationEvent(this.notification);
}

class RealTimeQuestionEvent extends CommunityEvent {
  final PostModel post;

  RealTimeQuestionEvent(this.post);
}

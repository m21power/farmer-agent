part of 'community_bloc.dart';

sealed class CommunityState extends Equatable {
  final List<PostModel> posts;
  final List<NotificationModel> notifications;
  const CommunityState({required this.posts, required this.notifications});

  @override
  List<Object> get props => [];
}

final class CommunityLoading extends CommunityState {
  CommunityLoading() : super(posts: [], notifications: []);
}

final class GetPostsLoading extends CommunityState {
  GetPostsLoading() : super(posts: [], notifications: []);
}

final class CommunityLoaded extends CommunityState {
  final List<PostModel> posts;
  final List<NotificationModel> notifications;
  const CommunityLoaded({required this.posts, required this.notifications})
      : super(posts: posts, notifications: notifications);

  @override
  List<Object> get props => [posts, notifications];
}

final class CommunityError extends CommunityState {
  final String message;
  final List<PostModel> posts;
  final List<NotificationModel> notifications;
  const CommunityError(
      {required this.message, required this.posts, required this.notifications})
      : super(posts: posts, notifications: notifications);

  @override
  List<Object> get props => [message, notifications, posts];
}

final class PostQuestionSuccessState extends CommunityState {
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const PostQuestionSuccessState(
      {required this.post, required this.notifications})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [post, notifications];
}

final class PostingLoadingState extends CommunityState {
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const PostingLoadingState({required this.post, required this.notifications})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [post, notifications];
}

final class ReplyQuestionSuccessState extends CommunityState {
  final ReplyModel replyModel;
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const ReplyQuestionSuccessState(
      {required this.replyModel,
      required this.post,
      required this.notifications})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [replyModel, notifications, post];
}

// final class ReplyQuestionLoadingState extends CommunityState {}

final class GetNotificaionSuccessState extends CommunityState {
  final List<NotificationModel> notifications;
  final List<PostModel> post;
  const GetNotificaionSuccessState(
      {required this.notifications, required this.post})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [notifications, post];
}

final class InternetConnectedState extends CommunityState {
  final List<PostModel> posts;
  final List<NotificationModel> notifications;
  final bool isConnected;
  const InternetConnectedState(
      {required this.posts,
      required this.notifications,
      required this.isConnected})
      : super(posts: posts, notifications: notifications);
  @override
  List<Object> get props => [posts, notifications, isConnected];
}

final class ReplyFailedState extends CommunityState {
  final String message;
  final List<NotificationModel> notifications;
  final List<PostModel> post;
  ReplyFailedState(
      {required this.message, required this.notifications, required this.post})
      : super(notifications: notifications, posts: post);
  @override
  List<Object> get props => [posts, notifications, message];
}

final class DeletePostSuccessState extends CommunityState {
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const DeletePostSuccessState(
      {required this.post, required this.notifications})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [post, notifications];
}

final class UpdatePostSuccessState extends CommunityState {
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const UpdatePostSuccessState(
      {required this.post, required this.notifications})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [post, notifications];
}

final class EditReplySuccessState extends CommunityState {
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const EditReplySuccessState({required this.post, required this.notifications})
      : super(posts: post, notifications: notifications);
  @override
  List<Object> get props => [post, notifications];
}

final class DeleteReplySuccessState extends CommunityState {
  final String questionId;
  final List<PostModel> post;
  final List<NotificationModel> notifications;
  const DeleteReplySuccessState(
      {required this.post,
      required this.notifications,
      required this.questionId})
      : super(
          posts: post,
          notifications: notifications,
        );
  @override
  List<Object> get props => [post, notifications, questionId];
}

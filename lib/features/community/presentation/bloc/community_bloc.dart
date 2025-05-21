import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maize_guard/core/network/network_info.dart';
import 'package:maize_guard/features/community/domain/usecases/delete_post_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/delete_reply_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/edit_reply_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/get_notification_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/listen_notification_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/listen_question_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/post_question_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/seen_notification_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/update_post_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../dependency_injection.dart';
import '../../../../main.dart';
import '../../domain/entities/post_entities.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/post_reply_usecase.dart';

part 'community_event.dart';
part 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final GetPostUsecase getPostUsecase;
  final PostQuestionUsecase postQuestionUsecase;
  final PostReplyUsecase postReplyUsecase;
  final GetNotificationUsecase getNotificationUsecase;
  final SeenNotificationUsecase seenNotificationUsecase;
  final DeletePostUsecase deletePostUsecase;
  final UpdatePostUsecase updatePostUsecase;
  final DeleteReplyUsecase deleteReplyUsecase;
  final EditReplyUsecase editReplyUsecase;
  final ListenNotificationUsecase listenNotificationUsecase;
  final ListenQuestionUsecase listenQuestionUsecase;

  bool prevInternet = true;
  List<PostModel> posts = [];
  List<NotificationModel> notifications = [];
  CommunityBloc({
    required this.getPostUsecase,
    required this.postQuestionUsecase,
    required this.postReplyUsecase,
    required this.getNotificationUsecase,
    required this.seenNotificationUsecase,
    required this.deletePostUsecase,
    required this.updatePostUsecase,
    required this.deleteReplyUsecase,
    required this.editReplyUsecase,
    required this.listenNotificationUsecase,
    required this.listenQuestionUsecase,
  }) : super(CommunityLoading()) {
    listenNotificationUsecase().listen((notification) {
      add(RealTimeNotificationEvent(notification));
    });

    listenQuestionUsecase().listen((question) {
      add(RealTimeQuestionEvent(question));
    });
    on<GetPostsEvent>((event, emit) async {
      print("GetPostsEvent");
      emit(CommunityLoading());
      final result = await getPostUsecase();
      result.fold(
          (failure) => emit(CommunityError(
              message: failure.message,
              posts: posts,
              notifications: notifications)), (post) {
        posts = post;
        emit(CommunityLoaded(posts: posts, notifications: notifications));
      });
    });
    on<PostQuestionEvent>((event, emit) async {
      print("PostQuestionEvent");
      var p = PostModel(
          id: "temp-${DateTime.now().millisecondsSinceEpoch}",
          author: "author",
          role: "role",
          autorId: "autorId",
          question: "question",
          isPosting: true,
          createdAt: DateTime.now(),
          replies: []);
      posts.insert(0, p);
      emit(PostingLoadingState(post: posts, notifications: notifications));
      final result = await postQuestionUsecase(event.image, event.question);
      posts.removeWhere((post) => post.isPosting == true);

      result.fold(
          (failure) => emit(CommunityError(
              message: failure.message,
              posts: posts,
              notifications: notifications)), (post) {
        posts.insert(0, post);
        for (int i = 0; i < posts.length; i++) {
          if (posts[i].isPosting == true) {
            print("Found a dummy post at index $i with id: ${posts[i].id}");
          }
        }

        emit(PostQuestionSuccessState(
            post: posts, notifications: notifications));
      });
    });
    on<ReplyQuestionEvent>((event, emit) async {
      print("ReplyQuestionEvent");
      final result = await postReplyUsecase(event.questionId, event.reply);
      result.fold((failure) {
        emit(ReplyFailedState(
          message: failure.message,
          post: posts,
          notifications: notifications,
        ));
      }, (reply) {
        print("reply: $reply");
        final index = posts.indexWhere((post) => post.id == event.questionId);
        print("index: $index");
        print("posts: ${posts[index].replies.length}");
        if (index != -1) {
          posts[index] = posts[index].copyWith(
            replies: [...posts[index].replies, reply],
          );
        } else {
          print("Post not found");
        }
        print("posts: ${posts[index].replies.length}");
        emit(ReplyQuestionSuccessState(
            replyModel: reply, notifications: notifications, post: posts));
      });
    });

    on<GetNotificationEvent>((event, emit) async {
      final result = await getNotificationUsecase();
      print(result);
      result.fold(
          (l) => () {
                print("error: $l");
              }, (res) {
        print("result: $res");
        notifications = res;
        emit(GetNotificaionSuccessState(
            notifications: notifications, post: posts));
      });
    });
    on<SeenNotificationEvent>(
      (event, emit) async {
        await seenNotificationUsecase(event.notificationId);
        notifications.removeWhere(
            (notification) => notification.id == event.notificationId);
        print("SeenNotificationEvent: ${event.notificationId}");
      },
    );
    on<CheckInternetEvent>((event, emit) async {
      while (true) {
        final result = await NetworkInfoImpl().isConnected;
        if (!result) {
          prevInternet = false;
          emit(InternetConnectedState(
              posts: posts, notifications: notifications, isConnected: false));
        } else {
          if (!prevInternet) {
            prevInternet = true;
            add(GetPostsEvent());
            emit(InternetConnectedState(
                posts: posts, notifications: notifications, isConnected: true));
          }
        }
        await Future.delayed(Duration(seconds: 1));
      }
    });
    on<DeletePostEvent>((event, emit) async {
      print("DeletePostEvent");
      final result = await deletePostUsecase(event.questionId);
      result.fold((failure) {
        emit(CommunityError(
            message: failure.message,
            posts: posts,
            notifications: notifications));
      }, (success) {
        print("DeletePostEvent: ${event.questionId}");
        posts = posts.where((post) => post.id != event.questionId).toList();
        emit(DeletePostSuccessState(post: posts, notifications: notifications));
      });
    });
    on<UpdatePostEvent>((event, emit) async {
      print("UpdatePostEvent");
      final result = await updatePostUsecase(event.questionId, event.question);
      result.fold((failure) {
        emit(CommunityError(
            message: failure.message,
            posts: posts,
            notifications: notifications));
      }, (success) {
        final index = posts.indexWhere((post) => post.id == event.questionId);
        if (index != -1) {
          posts[index].question = event.question;
          emit(UpdatePostSuccessState(
              post: posts, notifications: notifications));
        }
      });
    });
    on<EditReplyEvent>((event, emit) async {
      print("EditReplyEvent");
      final result = await editReplyUsecase(
          event.questionId, event.commentId, event.reply);
      result.fold((failure) {
        emit(CommunityError(
            message: failure.message,
            posts: posts,
            notifications: notifications));
      }, (reply) {
        final index = posts.indexWhere((post) => post.id == event.questionId);
        if (index != -1) {
          final replyIndex = posts[index]
              .replies
              .indexWhere((reply) => reply.commentId == event.commentId);
          if (replyIndex != -1) {
            posts[index].replies[replyIndex].message = event.reply;
            emit(EditReplySuccessState(
                post: posts, notifications: notifications));
          }
        }
      });
    });
    on<DeleteReplyEvent>((event, emit) async {
      print("DeleteReplyEvent");
      final result =
          await deleteReplyUsecase(event.questionId, event.commentId);
      result.fold((failure) {
        emit(CommunityError(
            message: failure.message,
            posts: posts,
            notifications: notifications));
      }, (success) {
        final index = posts.indexWhere((post) => post.id == event.questionId);
        if (index != -1) {
          posts[index]
              .replies
              .removeWhere((reply) => reply.commentId == event.commentId);
          emit(DeleteReplySuccessState(
              post: posts,
              notifications: notifications,
              questionId: event.questionId));
        }
      });
    });
    on<RealTimeNotificationEvent>((event, emit) {
      var userid = sl<SharedPreferences>().getString("userid");
      var postid = event.notification.questionId;
      for (var pos in posts) {
        if (pos.id == postid) {
          if (pos.autorId == userid) {
            return;
          }
        }
      }
      print("RealTimeNotificationEvent");
      showUserActionNotification(
          event.notification.author, 'added a new comment');
      print(event.notification);
      final updatedNotifications = [event.notification, ...notifications];
      ReplyModel replyModel = ReplyModel(
          questionId: event.notification.questionId,
          commentId: event.notification.replyId,
          author: event.notification.author,
          role: event.notification.role,
          message: event.notification.message,
          createdAt: event.notification.createdAt,
          authorId: "1235test");
      final updatedPosts = posts.map((p) {
        if (p.id == event.notification.questionId) {
          return p.copyWith(replies: [...p.replies, replyModel]);
        }
        return p;
      }).toList();
      posts = updatedPosts;
      notifications = updatedNotifications;
      emit(CommunityLoaded(posts: posts, notifications: notifications));
    });

    on<RealTimeQuestionEvent>((event, emit) {
      if (event.post.autorId != sl<SharedPreferences>().getString("userid")) {
        print("RealTimeQuestionEvent");
        showUserActionNotification(event.post.author, 'added a new question');
        final updatedPosts = [event.post, ...posts];
        NotificationModel notification = NotificationModel(
          id: event.post.id,
          author: event.post.author,
          role: event.post.role,
          message: event.post.question,
          createdAt: event.post.createdAt,
          questionId: event.post.id,
          replyId: "",
        );
        final updatedNotifications = [notification, ...notifications];
        notifications = updatedNotifications;
        posts = updatedPosts;
        emit(CommunityLoaded(posts: posts, notifications: notifications));
      }
    });
  }
  void showUserActionNotification(String name, String action) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'user_action_channel',
      'User Actions',
      channelDescription: 'Shows when a user adds a question or comment',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final message = '$name $action';

    flutterLocalNotificationsPlugin.show(
      0,
      '📢 New Activity',
      message,
      notificationDetails,
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/constant/api_constant.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/core/network/network_info.dart';
import 'package:maize_guard/features/community/domain/entities/post_entities.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../core/constant/socket_helper.dart';

class CommunityRepoImpl implements CommunityRepo {
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  final http.Client client;
  IO.Socket get socket => SocketManager.socket;

  // final IO.Socket socket;
  CommunityRepoImpl({
    required this.networkInfo,
    required this.sharedPreferences,
    required this.client,
    // required this.socket,
  }) {
    _initSocket();
  }
  final _notificationController =
      StreamController<NotificationModel>.broadcast();
  final _questionController = StreamController<PostModel>.broadcast();

  void _initSocket() {
    socket.on('new_notification', (data) {
      print("new notification");
      print(data);
      final notification = NotificationModel.fromMap(data);
      _notificationController.add(notification);
    });
    socket.on('new_question', (data) {
      final question = PostModel.fromMap(data);
      _questionController.add(question);
    });
  }

  @override
  Future<Either<Failure, void>> deletePost(String questionId) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.delete(
          Uri.parse("${ApiConstant.baseUrl}/questions/$questionId"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
        if (response.statusCode == 200) {
          return Right(Void);
        } else {
          return Left(ServerFailure(message: "Failed to delete post"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connections!"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editPost(
      String questionId, String question) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.put(
          Uri.parse("${ApiConstant.baseUrl}/questions/$questionId"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"question": question}),
        );
        if (response.statusCode == 200) {
          // var data = json.decode(response.body);
          // PostModel post = PostModel.fromMap(data["question"]);
          return Right(Void);
        } else {
          return Left(ServerFailure(message: "Failed to edit post"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connections!"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getPosts() async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.get(
          Uri.parse("${ApiConstant.baseUrl}/questions"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List<PostModel> posts = [];
          for (var d in data["questions"]) {
            posts.add(PostModel.fromMap(d));
          }
          return Right(posts);
        } else {
          return Left(ServerFailure(message: "Failed to load posts"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connection"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostModel>> postQuestion(
      File? file, String question) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var uri = Uri.parse("${ApiConstant.baseUrl}/questions");
        var request = http.MultipartRequest('POST', uri)
          ..headers.addAll({
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          })
          ..fields['question'] = question;

        if (file != null) {
          var multipartFile = await http.MultipartFile.fromPath(
            'image',
            file.path,
          );
          request.files.add(multipartFile);
        }
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        print("response: ${response.body}");
        if (response.statusCode == 201) {
          var data = json.decode(response.body);
          PostModel post = PostModel.fromMap(data["question"]);
          return Right(post);
        } else {
          return Left(ServerFailure(message: "Failed to post question"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connection"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReplyModel>> postReply(
      String questionId, String reply) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.post(
            Uri.parse("${ApiConstant.baseUrl}/questions/${questionId}/replies"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"message": reply}));
        print(response.body);
        print(response.statusCode);
        if (response.statusCode == 201) {
          var data = jsonDecode(response.body);
          final ReplyModel replyModel = ReplyModel.fromJson(data["reply"]);
          return Right(replyModel);
        } else {
          return Left(ServerFailure(message: "Failed to reply"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connection"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> seenNotification(String notificationId) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.post(
            Uri.parse(
                "${ApiConstant.baseUrl}/notification/seen/$notificationId"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            });
        if (response.statusCode == 200) {
          return;
        } else {
          print("Failed to seen notification");
        }
      } else {
        print("No internet connection");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<Either<Failure, void>> editReply(
      String questionId, String commentId, String reply) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.put(
            Uri.parse(
                "${ApiConstant.baseUrl}/questions/${questionId}/replies/${commentId}"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"message": reply}));
        if (response.statusCode == 200) {
          return Right(Void);
        } else {
          return Left(ServerFailure(message: "Failed to edit reply"));
        }
      } else
        return Left(ServerFailure(message: "No internet Connection!"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReply(
      String questionId, String commentId) async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        var response = await client.delete(
            Uri.parse(
                "${ApiConstant.baseUrl}/questions/${questionId}/replies/${commentId}"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            });
        if (response.statusCode == 200) {
          return Right(Void);
        } else {
          return Left(ServerFailure(message: "Failed to delete reply"));
        }
      } else
        return Left(ServerFailure(message: "No internet Connection!"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      if (await networkInfo.isConnected) {
        var token = sharedPreferences.getString("token");
        print("token: $token");
        var response = await client
            .get(Uri.parse("${ApiConstant.baseUrl}/notification/"), headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        });
        var data = json.decode(response.body);

        if (response.statusCode == 200) {
          final List<NotificationModel> notifications = [];
          for (var d in data["notifications"]) {
            notifications.add(NotificationModel.frmMap(d));
          }
          return Right(notifications);
        } else {
          return Left(ServerFailure(message: "Failed to load notifications"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connections"));
      }
    } catch (e) {
      print(e.toString());
      return Left(ServerFailure(message: "Unable to get notifications"));
    }
  }

  @override
  Stream<NotificationModel> notificationStream() {
    return _notificationController.stream;
  }

  @override
  Stream<PostModel> questionStream() {
    return _questionController.stream;
  }
}

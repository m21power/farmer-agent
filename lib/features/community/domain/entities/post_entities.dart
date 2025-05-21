import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PostModel {
  final String id;
  final String author;
  final String autorId;
  final String role;
  String question;
  final DateTime createdAt;
  final String? imageUrl;
  final List<ReplyModel> replies;
  bool? isPosting = false;
  PostModel({
    required this.id,
    required this.author,
    required this.role,
    required this.autorId,
    required this.question,
    required this.createdAt,
    this.imageUrl,
    this.isPosting,
    required this.replies,
  });
  PostModel copyWith({
    String? id,
    String? author,
    String? autorId,
    String? role,
    String? question,
    DateTime? createdAt,
    String? imageUrl,
    List<ReplyModel>? replies,
    bool? isPosting,
  }) {
    return PostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      autorId: autorId ?? this.autorId,
      role: role ?? this.role,
      question: question ?? this.question,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isPosting: isPosting ?? this.isPosting,
      replies: replies ?? this.replies,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['questionId'],
      author: json['author'],
      autorId: json['autorId'],
      role: json['role'],
      question: json['question'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((reply) => ReplyModel.fromJson(reply))
              .toList() ??
          [],
    );
  }
  factory PostModel.fromMap(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'],
      author: json['author'],
      autorId: json['authorId'],
      role: json['role'],
      question: json['question'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((reply) => ReplyModel.fromJson(reply))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': id,
      'author': author,
      'role': role,
      'question': question,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}

class ReplyModel {
  final String commentId;
  final String author;
  final String role;
  final String? questionId;
  String message;
  final String authorId;
  final DateTime createdAt;

  ReplyModel(
      {required this.commentId,
      required this.author,
      required this.role,
      this.questionId,
      required this.message,
      required this.createdAt,
      required this.authorId});

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      commentId: json['_id'],
      author: json['author'],
      role: json['role'],
      authorId: json["authorId"],
      message: json['message'],
      questionId: json['questionId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'author': author,
      'role': role,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

extension ReplyCopy on ReplyModel {
  ReplyModel copyWith({
    String? message,
  }) {
    return ReplyModel(
        commentId: commentId,
        author: author,
        role: role,
        questionId: questionId,
        message: message ?? this.message,
        createdAt: createdAt,
        authorId: authorId);
  }
}

class NotificationModel {
  final String id;
  final String questionId;
  final String replyId;
  final String author;
  final String message;
  final String role;
  final DateTime createdAt;
  NotificationModel({
    required this.id,
    required this.replyId,
    required this.author,
    required this.message,
    required this.role,
    required this.questionId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'questionId': questionId,
      'replyId': replyId,
      'author': author,
      'message': message,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    print("***************");
    print(map);
    return NotificationModel(
      id: map['_id'] as String,
      questionId: map['questionId'] as String,
      replyId: map["replayId"],
      author: map["author"],
      message: map["message"],
      role: map["role"],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  factory NotificationModel.frmMap(Map<String, dynamic> map) {
    print("***************");
    print(map);
    return NotificationModel(
      id: map['_id'] as String,
      questionId: map['questionId'] as String,
      replyId: map["replayId"] ?? "123",
      author: map["author"] ?? "Unknown",
      message: map["message"] ?? "No message",
      role: map["role"] ?? "Unknown",
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

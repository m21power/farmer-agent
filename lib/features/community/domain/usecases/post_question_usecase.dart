import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/community/domain/entities/post_entities.dart';
import 'package:maize_guard/features/community/domain/repository/community_repo.dart';

class PostQuestionUsecase {
  final CommunityRepo communityRepo;
  PostQuestionUsecase({required this.communityRepo});
  Future<Either<Failure, PostModel>> call(File? file, String question) {
    return communityRepo.postQuestion(file, question);
  }
}

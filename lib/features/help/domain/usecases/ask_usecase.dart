import 'package:dartz/dartz.dart';
import 'package:maize_guard/features/help/domain/entities/history_entities.dart';

import '../../../../core/error/failure.dart';
import '../repository/help_repo.dart';

class AskUsecase {
  final AskRepository askRepository;

  AskUsecase({required this.askRepository});

  Future<Either<Failure, HistoryModel>> call(String imagePath) {
    return askRepository.ask(imagePath);
  }
}

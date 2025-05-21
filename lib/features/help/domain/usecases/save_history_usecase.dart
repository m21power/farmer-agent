import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/help/domain/entities/history_entities.dart';
import 'package:maize_guard/features/help/domain/repository/local_repo.dart';

class SaveHistoryUsecase {
  final LocalRepo localRepo;
  SaveHistoryUsecase({required this.localRepo});
  Future<Either<Failure, int>> call(HistoryModel history) {
    return localRepo.saveHistory(history);
  }
}

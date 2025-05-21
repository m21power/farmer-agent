import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/help/domain/repository/local_repo.dart';

import '../entities/history_entities.dart';

class GetHistoryUsecase {
  final LocalRepo localRepo;
  GetHistoryUsecase({required this.localRepo});
  Future<Either<Failure, List<HistoryModel>>> call() {
    return localRepo.getHistory();
  }
}

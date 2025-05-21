import 'package:dartz/dartz.dart';
import 'package:maize_guard/features/help/domain/repository/local_repo.dart';

import '../../../../core/error/failure.dart';

class DeleteHistoryUsecase {
  final LocalRepo localRepo;
  DeleteHistoryUsecase({required this.localRepo});
  Future<Either<Failure, void>> call(int id) {
    return localRepo.deleteHistory(id);
  }
}

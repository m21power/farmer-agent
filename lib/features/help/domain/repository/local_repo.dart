import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/help/domain/entities/history_entities.dart';

abstract class LocalRepo {
  Future<Either<Failure, int>> saveHistory(HistoryModel history);
  Future<Either<Failure, List<HistoryModel>>> getHistory();
  Future<Either<Failure, void>> deleteHistory(int id);
}

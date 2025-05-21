import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/help/data/repository/database.dart';
import 'package:maize_guard/features/help/domain/entities/history_entities.dart';
import 'package:maize_guard/features/help/domain/repository/local_repo.dart';

class LocalRepoImpl implements LocalRepo {
  final HistoryDatabase historyDatabase;
  LocalRepoImpl({required this.historyDatabase});
  @override
  Future<Either<Failure, void>> deleteHistory(int id) async {
    try {
      await historyDatabase.deleteHistory(id);
      return Right(Void);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HistoryModel>>> getHistory() async {
    try {
      var history = await historyDatabase.getAllHistory();
      return Right(history);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> saveHistory(HistoryModel history) async {
    try {
      var id = await historyDatabase.insertHistory(history);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

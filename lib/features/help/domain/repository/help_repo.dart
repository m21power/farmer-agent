import 'package:dartz/dartz.dart';
import 'package:maize_guard/features/help/domain/entities/history_entities.dart';

import '../../../../core/error/failure.dart';

abstract class AskRepository {
  Future<Either<Failure, HistoryModel>> ask(String imagePath);
}

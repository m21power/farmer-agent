import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/Resource/domain/entities/disease.dart';

abstract class GetInfoRepository {
  Future<Either<Failure, List<Disease>>> getInfo();
}

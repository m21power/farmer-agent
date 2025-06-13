import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/Resource/domain/entities/disease.dart';

abstract class GetInfoRepository {
  Future<Either<Failure, List<Disease>>> getInfo();
  Future<Either<Failure, Disease>> addDisease(Disease disease);
  Future<Either<Failure, Disease>> updateDisease(Disease disease);
  Future<Either<Failure, void>> deleteDisease(String id);
}

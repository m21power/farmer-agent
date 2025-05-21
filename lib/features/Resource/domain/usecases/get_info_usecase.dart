import 'package:dartz/dartz.dart';
import 'package:maize_guard/features/Resource/domain/repository/get_info_repo.dart';

import '../../../../core/error/failure.dart';
import '../entities/disease.dart';

class GetInfoUsecase {
  final GetInfoRepository repository;
  GetInfoUsecase({required this.repository});
  Future<Either<Failure, List<Disease>>> call() {
    return repository.getInfo();
  }
}

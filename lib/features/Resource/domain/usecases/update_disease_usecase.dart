import 'package:dartz/dartz.dart';
import 'package:maize_guard/features/Resource/domain/repository/get_info_repo.dart';

import '../../../../core/error/failure.dart';
import '../entities/disease.dart';

class UpdateDiseaseUsecase {
  final GetInfoRepository repository;
  UpdateDiseaseUsecase({required this.repository});
  Future<Either<Failure, Disease>> call(Disease disease) {
    return repository.updateDisease(disease);
  }
}

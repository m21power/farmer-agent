import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/Resource/domain/repository/get_info_repo.dart';

class DeleteDiseaseUsecase {
  final GetInfoRepository repository;
  DeleteDiseaseUsecase({required this.repository});
  Future<Either<Failure, void>> call(String diseaseId) {
    return repository.deleteDisease(diseaseId);
  }
}

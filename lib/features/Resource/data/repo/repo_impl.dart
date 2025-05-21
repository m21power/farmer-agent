import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/constant/api_constant.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/core/network/network_info.dart';
import 'package:maize_guard/features/Resource/domain/entities/disease.dart';
import 'package:maize_guard/features/Resource/domain/repository/get_info_repo.dart';
import 'package:http/http.dart' as http;

class RepoImpl implements GetInfoRepository {
  final NetworkInfo networkInfo;
  final http.Client client;
  RepoImpl({required this.client, required this.networkInfo});

  @override
  Future<Either<Failure, List<Disease>>> getInfo() async {
    try {
      if (await networkInfo.isConnected) {
        final response =
            await client.get(Uri.parse("${ApiConstant.baseUrl}/diseases"));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body)["data"];
          final List<Disease> diseases = [];
          for (var item in data) {
            diseases.add(Disease.fromJson(item));
          }
          return Right(diseases);
        } else {
          return Left(ServerFailure(message: 'Server Error'));
        }
      } else {
        return Left(ServerFailure(message: 'No Internet Connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

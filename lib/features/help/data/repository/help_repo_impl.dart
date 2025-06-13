import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/constant/api_constant.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/core/network/network_info.dart';
import 'package:maize_guard/features/help/domain/entities/history_entities.dart';
import 'package:maize_guard/features/help/domain/repository/help_repo.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AskRepositoryImpl implements AskRepository {
  final http.Client client;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  AskRepositoryImpl(
      {required this.client,
      required this.networkInfo,
      required this.sharedPreferences});
  @override
  Future<Either<Failure, HistoryModel>> ask(String imagePath) async {
    try {
      if (await networkInfo.isConnected) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${ApiConstant.baseUrl}/identify"),
        );
        request.headers.addAll({
          "Authorization": "Bearer ${sharedPreferences.getString("token")}",
        });
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(HistoryModel.fromJson(jsonDecode(response.body)));
        } else {
          return Left(ServerFailure(message: "Failed to upload image"));
        }
      } else {
        return Left(ServerFailure(message: "No internet connection"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

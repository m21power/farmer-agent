import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:maize_guard/core/error/failure.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';
import 'package:maize_guard/features/profile/domain/repository/profile_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constant/api_constant.dart';
import '../../../../core/network/network_info.dart';

class ProfileRepoImpl implements ProfileRepo {
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final http.Client client;
  ProfileRepoImpl({
    required this.sharedPreferences,
    required this.networkInfo,
    required this.client,
  });
  @override
  Future<Either<Failure, void>> updateProfile(User user) async {
    try {
      if (await networkInfo.isConnected) {
        String? token = sharedPreferences.getString('token');
        if (token != null) {
          final response = await client.put(
            Uri.parse("${ApiConstant.baseUrl}/farmer/update"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: user.toJson(),
          );

          if (response.statusCode == 200) {
            // don't forget to add to shared preference
            var resp = jsonDecode(response.body);
            await sharedPreferences.setString(
                "user", jsonEncode(resp["Farmer"]));
            return Future.value(Right(null));
          } else {
            return Future.value(
                Left(ServerFailure(message: "Failed to update profile")));
          }
        } else {
          return Future.value(Left(ServerFailure(message: "Login first")));
        }
      } else {
        return Future.value(
            Left(ServerFailure(message: "No internet connection")));
      }
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }
}

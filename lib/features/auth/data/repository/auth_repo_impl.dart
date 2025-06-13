import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:maize_guard/core/constant/socket_helper.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';
import 'package:maize_guard/features/help/data/repository/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constant/api_constant.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepoImpl implements AuthRepository {
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final http.Client client;
  final HistoryDatabase historyDatabase;
  AuthRepoImpl({
    required this.sharedPreferences,
    required this.networkInfo,
    required this.client,
    required this.historyDatabase,
  });

  @override
  Future<Either<Failure, String>> isLoggedIn() async {
    String? token = sharedPreferences.getString('token');
    print("token");
    print(token);
    if (token != null) {
      SocketManager.initSocket(sharedPreferences.getString("userid")!);
      return Future.value(Right(token));
    } else {
      return Future.value(Left(ServerFailure(message: "Login first")));
    }
  }

  @override
  Future<Either<Failure, void>> logOut() async {
    if (await networkInfo.isConnected) {
      await sharedPreferences.clear();
      await historyDatabase.clearAllHistory();
      return Future.value(Right(null));
    } else {
      return Future.value(
          Left(ServerFailure(message: "No internet connection")));
    }
  }

  @override
  Future<Either<Failure, String>> login(
      {required String phone, required String password}) async {
    try {
      if (await networkInfo.isConnected) {
        phone = "+251${phone.substring(1)}";
        print(phone);
        print(password);
        print("${ApiConstant.baseUrl}/login");
        final response = await client
            .post(
              Uri.parse("${ApiConstant.baseUrl}/login"),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'phone': phone,
                'password': password,
              }),
            )
            .timeout(Duration(seconds: 20));
        print("Response: ${response.body}");
        print(response.statusCode);
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final token = jsonDecode(response.body)['token'];

          if (token == null) {
            return Future.value(Left(ServerFailure(message: "Login failed")));
          }
          var data = JwtDecoder.decode(token);
          await sharedPreferences.setString("userid", data["userId"]);
          await sharedPreferences.setString('token', token);
          await sharedPreferences.setString('phone', phone);
          await sharedPreferences.setString(
              "role", responseBody["user"]["role"]);
          await sharedPreferences.setString(
              "user", jsonEncode(responseBody["user"]));
          SocketManager.initSocket(data["userId"]);
          return Future.value(Right(token));
        } else {
          return Left(ServerFailure(message: responseBody["message"]));
        }
      } else {
        return Future.value(
            Left(ServerFailure(message: "No internet connection")));
      }
    } on TimeoutException {
      return Left(ServerFailure(message: "Timeout, please try later."));
    } catch (e) {
      print(e.toString());
      return Future.value(Left(ServerFailure(message: "Inavalid credentials")));
    }
  }

  @override
  Future<Either<Failure, User>> register(User user) async {
    if (await networkInfo.isConnected) {
      try {
        print(user.toJson());
        var input;
        if (user.email.isEmpty) {
          print("testing email");
          input = {
            'firstName': user.firstName,
            'lastName': user.lastName,
            'languagePref': "en",
            'phone': "+251${user.phone.substring(1)}",
            'password': user.password,
            'role': user.role,
          };
        } else {
          input = {
            'firstName': user.firstName,
            'lastName': user.lastName,
            'email': user.email,
            'languagePref': "en",
            'phone': "+251${user.phone.substring(1)}",
            'password': user.password,
            'role': user.role,
          };
        }
        final response = await client
            .post(
              Uri.parse("${ApiConstant.baseUrl}/register/farmer"),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(input),
            )
            .timeout(const Duration(seconds: 20));

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response: ${response.body}");
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          var token = responseBody['token'];
          if (token == null) {
            return Left(ServerFailure(message: responseBody["message"]));
          }
          var data = JwtDecoder.decode(token);
          await sharedPreferences.setString("userid", data["userId"]);
          await sharedPreferences.setString('token', token);
          await sharedPreferences.setString(
              'phone', "+251${user.phone.substring(1)}");
          await sharedPreferences.setString(
              "role", responseBody["user"]["role"]);
          await sharedPreferences.setString(
              "user", jsonEncode(responseBody["user"]));
          SocketManager.initSocket(data["userId"]);
          return Right(user);
        } else {
          return Left(ServerFailure(message: responseBody["message"]));
        }
      } on TimeoutException {
        return Left(ServerFailure(message: "Timeout, please try later"));
      } catch (e) {
        return left(ServerFailure(message: e.toString()));
      }
    } else {
      return Future.value(
          Left(ServerFailure(message: "No internet connection")));
    }
  }
}

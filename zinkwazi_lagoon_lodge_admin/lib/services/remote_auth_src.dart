import 'dart:convert';
import 'package:http/http.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../core/success.dart';
import '../data_models/user.dart';


const AUTH_URL = SERVER_URL + '/api/auth/';

abstract class RemoteAuthSourceContract {
  Future<ServerSuccess<User>> register(String jwt, User user);
  Future<ServerSuccess<User>> login(String username, String password);
  Future<ServerSuccess<List<User>>> getUsers(String jwt, String role);
  Future<User> activateUser(String jwt, String id, bool active);
  Future<ServerSuccess> updatePassword(String jwt, String updatedUserId, String newPassword);
}

class RemoteAuthSource implements RemoteAuthSourceContract {
  final Client http;
  RemoteAuthSource(this.http);

  @override
  Future<ServerSuccess<User>> register(String jwt, User user) async {
    final url = AUTH_URL + 'register';
    print(url);

    final userMap = {
      "username" : user.username,
      "email" : user.email,
      "password" : user.password,
      "role" : user.role,
    };

    try {
      // Send get request
      final response = await http
          .post(
          url,
          headers: {"Content-Type": "application/json", "auth-token" : jwt},
          body: json.encode(userMap))
          .timeout(TIME_OUT_DURATION
      );

      // Log status code
      print('[REGISTER] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonUser = json.decode(response.body);

        final user = User.fromJson(jsonUser);

        return ServerSuccess(jwt: jwt, object: user);
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  
  @override
  Future<ServerSuccess<User>> login(String username, String password) async {
    final url = AUTH_URL + 'login';
    print(url);

    final userMap = {
      "username" : username,
      "password" : password,
    };

    try {
      // Send get request
      final response = await http
          .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(userMap))
          .timeout(TIME_OUT_DURATION
      );

      // Log status code
      print('[LOGIN] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonUser = json.decode(response.body);

        final user = User.fromJson(jsonUser);

        print(response.headers.toString());
        print(response.headers['auth-token']);

        return ServerSuccess(jwt: jsonUser['authToken'], object: user);
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<ServerSuccess<List<User>>> getUsers(String jwt, String role) async {
    final url = AUTH_URL + 'users/$role';
    print(url);

    try {
      // Send get request
      final response = await http
          .get(url,
          headers: { "auth-token" : jwt },
          ).timeout(TIME_OUT_DURATION
      );

      // Log status code
      print('[GET USERS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonUsers = json.decode(response.body) as List;

        final userList = jsonUsers.map((jsonUser) => User.fromJson(jsonUser)).toList();
        print(userList);
        return ServerSuccess(jwt: jwt, object: userList);
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<User> activateUser(String jwt, String id, bool active) async {
    final url = AUTH_URL + 'user/activate/$id/$active';
    print(url);

    try {
      // Send post request
      final response = await http
          .patch(
          url,
          headers: {"Content-Type": "application/json", "auth-token" : jwt},
      ).timeout(TIME_OUT_DURATION);

      // Log status code
      print('[ACTIVATE USER] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonUser = json.decode(response.body);

        final user = User.fromJson(jsonUser);

        return user;
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<ServerSuccess> updatePassword(String jwt, String updatedUserId, String newPassword) async {
    final url = AUTH_URL + 'user/newpassword';
    print(url);

    final updateJson = {
      "userId" : updatedUserId,
      "newPassword" : newPassword,
    };

    try {
      // Send post request
      final response = await http
          .patch(
        url,
        headers: {"Content-Type": "application/json", "auth-token" : jwt},
        body: json.encode(updateJson),
      ).timeout(TIME_OUT_DURATION);

      // Log status code
      print('[UPDATE USER PASSWORD] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print(response.headers);
        return ServerSuccess(jwt: jwt);
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

}
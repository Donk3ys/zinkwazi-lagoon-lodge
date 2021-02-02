import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../core/success.dart';

import '../core/exception.dart';
import '../core/failure.dart';
import '../data_models/user.dart';
import '../services/local_data_src.dart';
import '../services/remote_auth_src.dart';


abstract class AuthRepositoryContract {
  Future<Either<Failure, String>> logout();
  Future<Either<Failure, User>> register(User user);
  Future<Either<Failure, User>> login(String username, String password);
  // Future<Either<Failure, String>> forgotPassword(String email);

  Future<Either<Failure, List<User>>> getUsers(String role);
  Future<Either<Failure, User>> activateUser(String id, bool active);
 // Future<Either<Failure, User>> getUser();
  // Future<Either<Failure, User>> getUserFromEmail(String email);
  // Future<Either<Failure, User>> getUserFromId(String uid);
  //
  // Future<Either<Failure, User>> updateEmail(User user, String password);
  Future<Either<Failure, Success>> updatePassword(String updatedUserId, String newPassword);
  // Future<Either<Failure, User>> updateUsername(User user, String password);

}

const LOGOUT_SUCCESS_MESSAGE = 'Logout success';

class AuthRepository implements AuthRepositoryContract {
  final RemoteAuthSourceContract remoteAuthSource;
  final LocalDataSourceContract localDataSource;

  AuthRepository({
    @required this.remoteAuthSource,
    @required this.localDataSource,
  });


  // AUTH FUNCTIONS WITHOUT CALL TO REMOTE SERVER
  @override
  Future<Either<Failure, String>> logout() async {
    try {
        print('[LOGOUT]: jwt == null');
        // Store nullJwt & nullUser
        await localDataSource.setJwt('null');

        // Success
        return right(LOGOUT_SUCCESS_MESSAGE);

    } on CacheException catch (e) {
      print(e);
      return left(CacheFailure(e.message));
    }
  }


  // AUTH FUNCTIONS TO REMOTE SERVER WITHOUT JWT -> LOGIN & REGISTER
  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try{
      // Run function
      final success = await remoteAuthSource.login(username, password);
      // Store jwt
      await localDataSource.setJwt(success.jwt);

      // Success -> object == <User>
      return right(success.object);

    } on RemoteDataSourceException catch (error) {
      print('auth repo: callRemoteDataSource.login: remote error' + error.message);
      return left(ServerFailure(error.message));
    } on CacheException catch (error) {
      print('auth repo: callRemoteDataSource.login: cache error' + error.message);
      return left(CacheFailure(error.message));
    }
  }

  // AUTH FUNCTIONS TO REMOTE SERVER WITH JWT

  @override
  Future<Either<Failure, User>> register(User user) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;
      final success = await remoteAuthSource.register(jwt, user);

      // Store jwt
      await localDataSource.setJwt(success.jwt);

      // Success -> object == <User>
      return right(success.object);

    } on RemoteDataSourceException catch (error) {
      print('auth repo: callRemoteDataSource.register: remote error' + error.message);
      return left(ServerFailure(error.message));
    } on CacheException catch (error) {
      print('auth repo: callRemoteDataSource.register: cache error' + error.message);
      return left(CacheFailure(error.message));
    }
  }


  Future<Either<Failure, List<User>>> getUsers(String role) async {
      try{
        // Get jwt
        final jwt = await localDataSource.jwt;
        // Run function that returns Success<User>
        final success = await remoteAuthSource.getUsers(jwt, role);
        // Store jwt
        await localDataSource.setJwt(success.jwt);

        // Success
        return right(success.object);

      } on RemoteDataSourceException catch (error) {
        print('Auth repo: remoteAuthSource.getUsers: remote error ' + error.message);
        return left(ServerFailure(error.message));
      } on CacheException catch (error) {
        print('Auth repo: remoteAuthSource.getUsers: cache error ' + error.message);
        return left(CacheFailure(error.message));
      }
  }

  @override
  Future<Either<Failure, User>> activateUser(String id, bool active) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final item = await remoteAuthSource.activateUser(jwt, id, active);
      return right(item);

    } on RemoteDataSourceException catch (error) {
      print('Auth repo: remoteAuthSource.activateUser: remote error ' + error.message);
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> updatePassword(String updatedUserId, String newPassword) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final success = await remoteAuthSource.updatePassword(jwt, updatedUserId, newPassword);
      return right(ServerSuccess());

    } on RemoteDataSourceException catch (error) {
      print('Auth repo: remoteAuthSource.updatePassword: remote error ' + error.message);
      return left(ServerFailure(error.toString()));
    }
  }

// @override
  // Future<Either<Failure, User>> getUser() async {
  //     return callRemoteDataSourceWithJwt((jwt) => remoteAuthSource.getUser(jwt));
  // }
  //
  // @override
  // Future<Either<Failure, User>> updateEmail(User user, String password) async {
  //     return callRemoteDataSourceWithJwt((jwt) => remoteAuthSource.updateEmail(jwt, user, password));
  // }
  //
  // @override
  // Future<Either<Failure, User>> updatePassword(User user, String oldPassword, String newPassword) async {
  //     return callRemoteDataSourceWithJwt((jwt) => remoteAuthSource.updatePassword(jwt, user, oldPassword, newPassword));
  // }


  // AUTH FUNCTIONS TO REMOTE SERVER WITH JWT AND NOT SAVE RETURNED USER


  // @override
  // Future<Either<Failure, User>> getUserFromId(String uid) async {
  //   final call = await callRemoteDataSourceWithJwtWithoutSavingUser((jwt) => remoteAuthSource.getUserFromId(jwt, uid));
  //
  //   try {
  //     // check if call returns a user and create a local storage chat from that user
  //     await call.fold((failure) => null, (user) async => await localDataSource.createChat(user));
  //   } on CacheException catch (e) {
  //     print('[getUserFromId CACHE EXCEPTION]: ${e.toString()}');
  //   }
  //
  //   return call;
  // }
  //
  // // General auth function
  // Future<Either<Failure, User>> callRemoteDataSourceWithJwtWithoutSavingUser(Function function) async {
  //   // Check if online
  //   if (!await networkInfo.isConnected) { return left(OfflineFailure()); }
  //
  //   try{
  //     // Get jwt
  //     final jwt = await localDataSource.jwt;
  //     // Run function that returns Success<User>
  //     final success = await function(jwt);
  //     // Store jwt & user
  //     await localDataSource.setJwt(success.jwt);
  //
  //     // Success
  //     return right(success.object);
  //
  //   } on RemoteDataSourceException catch (e) {
  //     print('auth repo: callRemoteDataSourceWithJwtWithoutSavingUser: remote error' + e.message);
  //     return left(ServerFailure(e.message));
  //   } on CacheException catch (e) {
  //     print('auth repo: callRemoteDataSourceWithJwtWithoutSavingUser: cache error' + e.message);
  //     return left(CacheFailure(e.message));
  //   }
  // }

}

// @override
// Future<Either<Failure, User>> getStoredUser() async {
//   try {
//     return right(await localDataSource.user);
//   } on CacheException catch (e) {
//     print('getStoredUser: [CACHE ERROR]: ${e.message}');
//     return left(CacheFailure(e.message));
//   }
// }


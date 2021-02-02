import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class OfflineFailure extends Failure {
  final String message =
      '[CONNECTION FAILURE] Device has  no internet connection';

  @override
  String toString() {
    return message;
  }
}

class ServerFailure extends Failure {
  final String message;

  ServerFailure(this.message);

  @override
  String toString() {
    return message;
  }
}

class CacheFailure extends Failure {
  final String message;

  CacheFailure(this.message);

  @override
  String toString() {
    return message;
  }
}
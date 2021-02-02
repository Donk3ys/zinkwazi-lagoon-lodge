import 'package:equatable/equatable.dart';

abstract class Success extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerSuccess<Type> extends Success {
  final String jwt;
  final Type object;

  ServerSuccess({
    this.jwt,
    this.object,
  });

  @override
  String toString() {
    return '$object';
  }
}

class CacheSuccess extends Success {
  final String message;

  CacheSuccess(this.message);

  @override
  String toString() {
    return message;
  }
}
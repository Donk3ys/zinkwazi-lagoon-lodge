import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../core/success.dart';
import '../core/exception.dart';
import '../core/failure.dart';
import '../data_models/menuOrder.dart';
import '../services/local_data_src.dart';
import '../services/remote_order_src.dart';

abstract class OrderRepositoryContract {
  Future<Either<Failure, List<MenuOrder>>> getCurrentOrderList();
  Future<Either<Failure, List<MenuOrder>>> getOrderListByDate(DateTime beginDate, DateTime endDate);
  Future<Either<Failure, Success>> preparedOrder(String id);
  Future<Either<Failure, Success>> deliveredOrder(String id);
//  Future<Either<Failure, MenuOrder>> placeOrder(MenuOrder currentOrder);
  Future initSocket();
  Stream<List<MenuOrder>> orderStream();
  updateStream();
  Future closeSockets();
  Future closeStreams();
}

class OrderRepository implements OrderRepositoryContract {
  final RemoteOrderSourceContract remoteOrderSource;
  final LocalDataSourceContract localDataSource;

  OrderRepository({
    @required this.remoteOrderSource,
    @required this.localDataSource,
  }) {
    updateStream();
  }

  StreamSubscription updateStreamSub;

  @override
  Future<Either<Failure, List<MenuOrder>>> getOrderListByDate(DateTime beginDate, DateTime endDate) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final allOrders = await remoteOrderSource.getOrdersByDate(jwt, beginDate, endDate);
      return right(allOrders);

    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }


  @override
  Future<Either<Failure, List<MenuOrder>>> getCurrentOrderList() async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final allOrders = await remoteOrderSource.getCurrentOrders(jwt);
      return right(allOrders);

    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> preparedOrder(String id) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final success = await remoteOrderSource.preparedOrder(jwt, id);
      return right(success);

    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deliveredOrder(String id) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final success = await remoteOrderSource.deliveredOrder(jwt, id);
      return right(success);

    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future initSocket() async {
    remoteOrderSource.initSocket();
  }

  @override
  Stream<List<MenuOrder>> orderStream() {
    return remoteOrderSource.orderStream();
  }

  @override
  void updateStream() {
    updateStreamSub = remoteOrderSource.updateStream().listen((jwt) {
      // TODO save new jwt
      getCurrentOrderList();
    });
  }

  @override
  Future closeSockets() async {
    remoteOrderSource.closeSockets();
  }

  @override
  Future closeStreams() async {
    remoteOrderSource.closeStreams();
    updateStreamSub.cancel();
  }
  
}
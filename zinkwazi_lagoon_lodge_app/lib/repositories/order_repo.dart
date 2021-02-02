import 'dart:async';

import 'package:dartz/dartz.dart';
import '../core/exception.dart';
import '../core/failure.dart';
import '../data_models/menuOrder.dart';
import '../services/local_data_src.dart';
import '../services/network_info.dart';
import '../services/remote_order_src.dart';


abstract class OrderRepositoryContract {
  Future<Either<Failure, MenuOrder>> placeOrder(String paymentId, MenuOrder currentOrder);
  Future<Either<Failure, List<MenuOrder>>> getOrderHistory();
  Future<List<MenuOrder>> getOrdersToStatusCheck();
  Future<Either<Failure, MenuOrder>> checkOrderStatus(MenuOrder order);
  // Socket
  Future initStreams();
  Future initSocket();
  Stream<bool> newConnectionStream();
  Stream<MenuOrder> orderStream();
  Future closeStreams();
  Future closeSocket();
}

class OrderRepository implements OrderRepositoryContract {
  final LocalDataSourceContract localDataSource;
  final NetworkInfoContract networkInfo;
  final RemoteOrderSourceContract remoteOrderSource;
  StreamController<MenuOrder> orderStreamController;

  OrderRepository(this.localDataSource, this.networkInfo, this.remoteOrderSource);

  @override
  Future<Either<Failure, MenuOrder>> placeOrder(String paymentId, MenuOrder currentOrder) async {
    try {
      // Check for internet connection
      if (!await networkInfo.isConnected) { return left(OfflineFailure()); }

      final placedOrder = await remoteOrderSource.placeOrder(paymentId, currentOrder);

      // Save order to local storage
      await localDataSource.saveOrder(placedOrder);

      return right(placedOrder);

    } on RemoteDataSourceException catch (error) {
      print(error.toString());
      return left(ServerFailure(error.toString()));
    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuOrder>>> getOrderHistory() async {
    try {
      return right(await localDataSource.orderHistory);

    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<List<MenuOrder>> getOrdersToStatusCheck() async {
    // Get orders from local storage
    return await localDataSource.ordersToCheck;
  }

    @override
  Future<Either<Failure, MenuOrder>> checkOrderStatus(MenuOrder order) async {
    try {
      // Check for internet connection
      if (!await networkInfo.isConnected) { return left(OfflineFailure()); }

        if (!order.prepared) {
          // Check remote server for updates to order
          final orderStatus = await remoteOrderSource.checkOrderPreparedStatus(order);
          // Update local copy of order
          if (orderStatus.prepared) {
            print("SAVING LOCAL PREPARED");
            // If order has been prepared update local copy & return updated order
            final updatedOrder = await localDataSource.updateOrderDeliveryStatus(orderStatus);
            // Return order updated
            return right(updatedOrder);
          }
        } else {
          // Check remote server for updates to order
          final orderStatus = await remoteOrderSource.checkOrderDeliveredStatus(order);
          // Update local copy of order
          if (orderStatus.delivered) {
            final updatedOrder = await localDataSource.updateOrderDeliveryStatus(orderStatus);
            // Return order updated
            return right(updatedOrder);
          }
        }

      // Return no orders found have been prepared
      return right(order);

    } on RemoteDataSourceException catch (error) {
      print(error.toString());
      return left(ServerFailure(error.toString()));
    } on CacheException catch (error) {
      print(error.toString());
      return left(CacheFailure(error.toString()));
    }
  }


  @override
  Future initStreams() async {
    remoteOrderSource.initStreams();
  }

  @override
  Future initSocket() async {
    remoteOrderSource.initSocket();
  }

  @override
  Stream<bool> newConnectionStream() {
    return remoteOrderSource.newConnectionStream();
  }


  @override
  Stream<MenuOrder> orderStream() {
    //final inputStream = remoteOrderSource.orderStream().asBroadcastStream();
    final inputStream = remoteOrderSource.orderStream().asBroadcastStream();
    orderStreamController = StreamController<MenuOrder>();

    try {
      // Check order for prepared or delivered
      inputStream.listen((order) async {
          final updatedOrder = await localDataSource.updateOrderDeliveryStatus(order);
          // Return order updated
          orderStreamController.add(updatedOrder);
      });
    } catch (error) {
      print(error.toString());
    }

    return orderStreamController.stream;
  }


  @override
  Future closeStreams() async {
    print('CLOSE STREAM CONTROLLERS]');
    if (orderStreamController != null) {
      orderStreamController.close();
    }
    remoteOrderSource.closeStreams();
  }

  @override
  Future closeSocket() async {
    remoteOrderSource.closeSocket();
  }

}
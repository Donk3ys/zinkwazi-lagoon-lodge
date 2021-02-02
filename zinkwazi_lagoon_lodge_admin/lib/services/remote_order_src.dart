import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../core/success.dart';
import '../data_models/menuOrder.dart';

const ORDER_URL = SERVER_URL + '/api/v1/menu/';

abstract class RemoteOrderSourceContract {
  Future<Success> preparedOrder(String jwt, String id);
  Future<Success> deliveredOrder(String jwt, String id);
  Future<List<MenuOrder>> getCurrentOrders(String jwt);
  Future<List<MenuOrder>> getOrdersByDate(String jwt, DateTime beginDate, DateTime endDate);
//  Future<MenuOrder> placeOrder(MenuOrder currentOrder);
//  Future<MenuOrder> checkOrderStatus(MenuOrder currentOrder);
// Socket
  Future initSocket();
  Stream<List<MenuOrder>> orderStream();
  Stream<String> updateStream();
  Future closeSockets();
  Future closeStreams();
}

class RemoteOrderSource implements RemoteOrderSourceContract {
  final Client http;
  RemoteOrderSource(this.http) {
    initStreams();
  }

  // SocketIO
  Socket socket = io(SERVER_URL, <String, dynamic>{
    'forceNew': true,
    'transports': ['websocket'],
    'autoConnect': false,
  });

  StreamController<List<MenuOrder>> orderStreamController;
  StreamController<String> updateStreamController;

  // Socket
  Future initStreams() async {
    print('RemoteOrderSource [STREAMS INITIALIZING]');
    orderStreamController = StreamController();
    updateStreamController = StreamController();
  }

  // Socket Receiving Messages
  @override
  Future initSocket() async {
    print('RemoteSocketSource [SOCKET INITIALIZING]');
    // If socket already connected then return
    if (socket.connected) { return; }

    // Connecting to server
    socket.on('connecting', (_) =>
        print('[SOCKET_IO CONNECTING]'));
    socket.on('connect_error', (e) =>
        print('[ERROR SOCKET_IO CONNECTION]: $e'));
    socket.on('connect', (_) async {
      print('[SOCKET_IO CONNECTED]: ${socket.id}');
      updateStreamController.add("updated jwt");
    });

    socket.on('updateCurrentOrders', (_) async {
      print('[ORDER UPDATED]: ');
      updateStreamController.add("updated jwt");
    });

    // Disconnect from server
    socket.on('disconnect', (_) {
      print('[SOCKET_IO DISCONNECTED]: ${socket.disconnected}');
    });

    // // Run Connect to server
    if (!socket.connected) { socket.connect(); }
  }


  // Listen to streams
  @override
  Stream<List<MenuOrder>> orderStream() {
    return orderStreamController.stream;
  }

  @override
  Stream<String> updateStream() {
    return updateStreamController.stream;
  }


  // REST CALLS
  @override
  Future<Success> deliveredOrder(String jwt, String id) async {
    // Add order id to url
    //final url = ORDER_URL + 'order/$id/delivered';
    final timestamp = DateTime.now().toLocal().toIso8601String();
    final deliveredMap = {
      "id" : id,
      "delivered" : true,
      "delivered_at" : timestamp,
      "jwt" : jwt,
    };

    try {
      socket.emit("orderStatusUpdated", deliveredMap);
      //socket.emit("updateOrder");

      // Send get request
      // final response = await http
      //     .post(url)
      //     .timeout(TIME_OUT_DURATION);
      //
      // // Log status code
      // print('[DELIVERED ORDER] Response Code: ${response.statusCode}');
      //
      // if (response.statusCode == 200) {
        return ServerSuccess();
      // }
      //
      // throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }


  @override
  Future<Success> preparedOrder(String jwt, String id) async {
    // Add order id to url
    //final url = ORDER_URL + 'order/$id/prepared';

    final timestamp = DateTime.now().toLocal().toIso8601String();
    final preparedMap = {
      "id" : id,
      "prepared" : true,
      "prepared_at" : timestamp,
      "delivered" : false,
      "jwt" : jwt,
    };

    try {
      print("UPDATING ORDER");
      socket.emit("orderStatusUpdated", preparedMap);
      //socket.emit("updateOrder");

      // // Send get request
      // final response = await http
      //     .post(url)
      //     .timeout(TIME_OUT_DURATION);
      //
      // // Log status code
      // print('[PREPARED ORDER] Response Code: ${response.statusCode}');
      //
      // if (response.statusCode == 200) {
        return ServerSuccess();
      // }

      // throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }


  @override
  Future<List<MenuOrder>> getCurrentOrders(String jwt) async {
    final url = ORDER_URL + 'orders/current';
    print(url);

    try {
      // Send get request
      final response = await http
          .get(url, headers: {"auth-token" : jwt})
          .timeout(TIME_OUT_DURATION);

      // Log status code
      print('[GET CURRENT ORDERS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List;

        final orderList = jsonList.map((jsonItem) => MenuOrder.fromJson(jsonItem)).toList();

        if (socket.connected) { orderStreamController.add(orderList); }
        return orderList;
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }


  @override
  Future<List<MenuOrder>> getOrdersByDate(String jwt, DateTime beginDate, DateTime endDate) async {
    final url = ORDER_URL + 'orders/dates';

    final datesMap = {
      "beginDate": beginDate.toIso8601String().substring(0, 10),
      "endDate": endDate.toIso8601String().substring(0, 10)
    };

    try {
      // Send post request
      final response = await http
          .post(
          url,
          headers: {"Content-Type": "application/json", "auth-token" : jwt},
          body: json.encode(datesMap))
          .timeout(TIME_OUT_DURATION
      );

      // Log status code
      print('[GET ORDERS BY DATE] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List;

//         print('DATE ORDERS : $jsonList');

        final orderList = jsonList.map((jsonItem) => MenuOrder.fromJson(jsonItem)).toList();

//        for (var order in orderList) {
//          for (var item in order.itemList) {
//            print("${order.id} : ${item.name} ${item.selectedOptionList}");
//          }
//        }

        return orderList;
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }


// Dispose
  Future closeSockets() async {
    if (socket != null && socket.connected) {
      print("CLOSING SOCKETS");
      socket.disconnect();
    }
  }

  @override
  Future closeStreams() async {
    print("CLOSING STREAMS");
    if (orderStreamController != null ) { orderStreamController.close(); }
    if (updateStreamController != null ) { updateStreamController.close(); }
  }


}

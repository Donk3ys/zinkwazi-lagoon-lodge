import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../data_models/menuOrder.dart';


const ORDER_URL = SERVER_URL + '/api/v1/menu/order';

abstract class RemoteOrderSourceContract {
  Future<MenuOrder> placeOrder(String paymentId, MenuOrder currentOrder);
  Future<MenuOrder> checkOrderPreparedStatus(MenuOrder currentOrder);
  Future<MenuOrder> checkOrderDeliveredStatus(MenuOrder currentOrder);
  // Socket
  Future initStreams();
  Future initSocket();
  Stream<bool> newConnectionStream();
  Stream<MenuOrder> orderStream();
  Future closeStreams();
  Future closeSocket();
}

class RemoteOrderSource implements RemoteOrderSourceContract {
  final Client http;
  RemoteOrderSource(this.http);

  // SocketIO
  Socket socket = io(SERVER_URL, <String, dynamic>{
  'forceNew': true,
  'transports': ['websocket'],
  'autoConnect': false,
  });

  StreamController<bool> newConnectionStreamController;
  StreamController<MenuOrder> orderStreamController;

  // Socket
  Future initStreams() async {
    print('[STREAMS INITIALIZING]');
    newConnectionStreamController = StreamController();
    orderStreamController = StreamController();
  }

  // Socket Receiving Messages
  @override
  Future initSocket() async {
    print('[SOCKET INITIALIZING]');

    socket = io(SERVER_URL, <String, dynamic>{
      'forceNew': true,
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connecting to server
    socket.on('connecting', (_) =>
        print('[SOCKET_IO CONNECTING]'));
    socket.on('connect_error', (e) =>
        print('[ERROR SOCKET_IO CONNECTION]: $e'));
    socket.on('connect', (_) {
      print('[SOCKET_IO CONNECTED]: ${socket.id}');
      newConnectionStreamController.add(true);
    });

    socket.on('orderStatusUpdated', (orderData) {
      print('[ORDER UPDATED]: ');
      print(orderData.toString());

      // Check order from remote source has been prepared / delivered
      final checkedOrder = MenuOrder(
        id: orderData["id"],
        dayId: null,
        itemList: null,
        createdAt: null,
        preparedAt: orderData["prepared_at"] != null ? DateTime.parse(
            orderData["prepared_at"]) : null,
        prepared: orderData["prepared"],
        deliveredAt: orderData["delivered_at"] != null ? DateTime.parse(
            orderData["delivered_at"]) : null,
        delivered: orderData["delivered"],
      );

      orderStreamController.add(checkedOrder);
    });

    // Disconnect from server
    socket.on('disconnect', (_) {
      print('[SOCKET_IO DISCONNECTED]: ${socket.disconnected}');
    });

    // Run Connect to server
    if (!socket.connected) {
      socket.connect();
    }
    while (socket.id == null){
      await Future.delayed(Duration(milliseconds: 20), () {});
    }
  }


  // Listen to streams
  @override
  Stream<bool> newConnectionStream() {
    return newConnectionStreamController.stream;
  }

  @override
  Stream<MenuOrder> orderStream() {
    return orderStreamController.stream;
  }


  @override
  Future<MenuOrder> placeOrder(String paymentId, MenuOrder currentOrder) async {
    final url = ORDER_URL + '/place';
    String socketId;

    try {
      while (socketId == null) {
        await initSocket();
        socketId = socket.id;
      }

      // Create a list of item maps with option ids
      List<Map> itemList = [];
      for (var item in currentOrder.itemList) {

        // Create a list of all option ids for current item
        List<int> optionIdList = [];
        for(var option in item.selectedOptionList){
          optionIdList.add(int.parse(option.id));
        }

        // Create map & add map to list
        final itemMap = {
          "item_id": int.parse(item.id),
          "option_ids": optionIdList,
        };
        itemList.add(itemMap);
      }

      final currentOrderMap = {
        "socket_id" : socketId,
        "payment_id" : paymentId,
        "price": currentOrder.price,
        "items": itemList
      };

      //    print(json.encode(currentOrderMap));
      // Send get request
      print(url);
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode(currentOrderMap))
          .timeout(TIME_OUT_DURATION);

      // Log status code
      print('[PLACE ORDER] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var orderData = json.decode(response.body);


        final placedOrder = MenuOrder(
            id: orderData["id"].toString(),
            dayId: orderData["number"].toString(),
            itemList: currentOrder.itemList,
            createdAt: DateTime.parse(orderData["created_at"]),
            preparedAt: null,
            prepared: false,
            deliveredAt: null,
            delivered: false,
        );

        socket.emit("updateOrder");
        print("[ORDER PLACED] id: ${placedOrder.id} to socket:$socketId");
        return placedOrder;
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<MenuOrder> checkOrderPreparedStatus(MenuOrder order) async {
    if (!socket.connected) {
      await initSocket();
    }

    // Add order id to url
    final url = ORDER_URL + '/${order.id}/prepared/${socket.id}';

    try {
      print(url);
      if (socket.id == null) {throw RemoteDataSourceException("Socket not connected");}
      // Send get request
      final response = await http
          .get(url)
          .timeout(ORDER_STATUS_TIME_OUT_DURATION);

      // Log status code
      print('[CHECK ORDER] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var orderData = json.decode(response.body);

        // Create new order from remote source updating prepared or not
        final checkedOrder = MenuOrder(
          id: order.id,
          dayId: order.dayId,
          itemList: order.itemList,
          createdAt: order.createdAt,
          preparedAt: orderData["prepared_at"] != null ? DateTime.parse(
              orderData["prepared_at"]) : null,
          prepared: orderData["prepared"],
          deliveredAt: null,
          delivered: false,
        );

        //print(checkedOrder.toString());
        return checkedOrder;
      }

    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
    //throw RemoteDataSourceException('Unexpected Error: Order Prepared Update');
    throw RemoteDataSourceException('500');
  }

  @override
  Future<MenuOrder> checkOrderDeliveredStatus(MenuOrder order) async {
    if (!socket.connected) {
      await initSocket();
    }

    // Add order id to url
    final url = ORDER_URL + '/${order.id}/delivered/${socket.id}';

    try {
        print(url);
        if (socket.id == null) {throw RemoteDataSourceException("Socket not connected");}
        // Send get request
        final response = await http
            .get(url)
            .timeout(ORDER_STATUS_TIME_OUT_DURATION);

        // Log status code
        print('[CHECK ORDER DELIVERED] Response Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          var orderData = json.decode(response.body);

          // Create new order from remote source updating delivered or not
          final checkedOrder = MenuOrder(
            id: order.id,
            dayId: order.dayId,
            itemList: order.itemList,
            createdAt: order.createdAt,
            preparedAt: orderData["prepared_at"] != null ? DateTime.parse(
                orderData["prepared_at"]) : null,
            prepared: true,
            deliveredAt: orderData["delivered_at"] != null ? DateTime.parse(
                orderData["delivered_at"]) : null,
            delivered: orderData["delivered"],
          );

          //print(checkedOrder.toString());
          return checkedOrder;
        }
      } catch (error) {
        throw RemoteDataSourceException(error.toString());
      }
    //throw RemoteDataSourceException('Unexpected Error: Order Delivery Update');
    throw RemoteDataSourceException('500');

  }


// Dispose
  @override
  Future closeStreams() async {
    if (orderStreamController != null ) { orderStreamController.close(); }
    if (newConnectionStreamController != null ) { newConnectionStreamController.close(); }
  }

  @override
  Future closeSocket() async {
    if (socket != null && socket.connected) { socket.disconnect(); }
  }

}

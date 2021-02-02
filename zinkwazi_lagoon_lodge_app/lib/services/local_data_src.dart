import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data_models/itemOption.dart';
import '../data_models/item.dart';
import '../data_models/menuOrder.dart';

import '../core/exception.dart';
import '../core/success.dart';


abstract class LocalDataSourceContract {
  Future<List<MenuOrder>> get orderHistory;
  Future<List<MenuOrder>> get ordersToCheck;
  Future<Success> saveOrder(MenuOrder placedOrder);
  Future<MenuOrder> updateOrderDeliveryStatus(MenuOrder updatedOrder);
}

const ORDER_BOX = 'order_history';


class LocalDataSource implements LocalDataSourceContract {

  LocalDataSource() {
    initHive();
  }

  var orderBox;

  Future initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MenuOrderAdapter());
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(ItemOptionAdapter());
    print('[HIVE INIT COMPLETE]');

    orderBox = await Hive.openBox(ORDER_BOX);
  }

  // Getters

  @override
  Future<List<MenuOrder>> get orderHistory async {
    try {
      //print('[CACHE GET order history]');
      //var orderBox = await Hive.openBox(ORDER_BOX);

      // Check if chatBox exists
      if (!orderBox.isOpen) { throw CacheException('Order not saved to local storage'); }
      //print('Number of history orders: ${orderBox.length}');
      if (orderBox.isEmpty) { return []; }

      List<MenuOrder> orderHistory = [];

      // Get orders and add them to order list
      for (int i = 0; i < orderBox.length; i++) {
        final order = await orderBox.get(i);
        orderHistory.add(order);
        //print('Order from Local Storage: ${order.toString()}');
      }

      //await Hive.close();

      // Order list -> by delivered then date
      orderHistory = orderHistory.reversed.toList();
      //
      for (int i = 0; i < orderHistory.length; i++) {
        final order = orderHistory[i];

        if (!order.delivered) {
          orderHistory.removeAt(i);
          orderHistory.insert(0, order);
        }
      }

      print('[CACHE GET order history]: success');
      return orderHistory;
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<MenuOrder>> get ordersToCheck async {
    try {
      //print('[CACHE GET orders to check]');
      //var orderBox = await Hive.openBox(ORDER_BOX);

      // Check if chatBox exists
      if (!orderBox.isOpen) { throw CacheException('Order box not open'); }
      if (orderBox.isEmpty) { return []; }

      List<MenuOrder> ordersToCheck = [];

      // Get orders and add them to order list
      for (int i = 0; i < orderBox.length; i++) {
        final order = await orderBox.get(i);
        // Check if order delivered or not
        if (!order.delivered) { ordersToCheck.add(order); }
      }

      //await Hive.close();

      print('[CACHE GET orders to check]: success : number of ${ordersToCheck.length}');
      return ordersToCheck;
    } catch(e) {
      throw CacheException(e.toString());
    }
  }


  // Setters

  @override
  Future<Success> saveOrder(MenuOrder placedOrder) async {
    print('[CACHE STORE Placed order]: $placedOrder');
    try {
      // Try open orderBox
      //var orderBox = await Hive.openBox(ORDER_BOX);

      if (placedOrder == null) { throw CacheException('Order null, not saved to phone'); }
      if (placedOrder.itemList.isEmpty) { throw CacheException('Order empty, not saved to phone'); }

      // Add placed order to order box
      await orderBox.add(placedOrder);

      //await Hive.close();
      return CacheSuccess('[CACHE STORE PLACED ORDER] success');
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<MenuOrder> updateOrderDeliveryStatus(MenuOrder updatedOrder) async {
    print('[CACHE STORE update order delivery]: id: ${updatedOrder.id}');
    try {
      // Try open orderBox
      //var orderBox = await Hive.openBox(ORDER_BOX);

      // Check if chatBox exists
      if (!orderBox.isOpen) { throw CacheException('Order box not open'); }

      // Get orders and add them to order list
      for (int i = 0; i < orderBox.length; i++) {
        final order = await orderBox.get(i);
        // Check if order delivered or not
        if (order.id == updatedOrder.id) {
          final tempOrder = MenuOrder(
              id: order.id,
              dayId: order.dayId,
              itemList: order.itemList,
              createdAt: order.createdAt,
              prepared: updatedOrder.prepared,
              preparedAt: updatedOrder.preparedAt,
              delivered: updatedOrder.delivered,
              deliveredAt: updatedOrder.deliveredAt
          );

          // update order with temp order
          await orderBox.putAt(i, tempOrder);
          //print("ORDERS TO GET LENGTH: " + (await ordersToCheck).length.toString());

          return tempOrder;
        }
      }

      //await Hive.close();
      return throw CacheException('[HIVE ERROR]: Could not find order in local storage to update');
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

//  @override
//  Future<Success> createChat(User chatUser) async {
////    print('[CACHE CREATE CHAT] user: $chatUser');
//    try {
//      // Get current user
//      final currentUser = await user;
//      var chatsBox = await Hive.openBox(CHATS_BOX+currentUser.id);
//
//      // Check if chat already exists
//      for (int i = 0; i < chatsBox.length; i++) {
//        if (await chatsBox.get(i).user.id == chatUser.id) {
//
//          throw CacheException('[CACHED CHAT ALREADY EXISTS]: $chatUser');
//        }
//      }
//
//      // Create a chat object
//      final chat = Chat(user: chatUser, messageList: []);
//
//      // Add chat object to hive db chatList
//      await chatsBox.add(chat);
//
//      await Hive.close();
//      return (CacheSuccess('[CACHE CREATED CHAT] success: user: $chatUser'));
//    } catch (e) {
//      await Hive.close();
//      throw CacheException(e.toString());
//    }
//  }
//
//  @override
//  Future<Success> addMessageToChat(Message message) async {
////    print('[CACHE ADD MESSAGE]: message: $message');
//    try {
//      // Get current user
//      final currentUser = await user;
//      var chatsBox = await Hive.openBox(CHATS_BOX+currentUser.id);
//
//      // Check if chat already exists
//      for (int i = 0; i < chatsBox.length; i++) {
//
//        // Get id of chat user
//        final chat = await chatsBox.get(i);
//        final chatId = chat.user.id;
//
//        // If ids match add message
//        if (chatId == message.fromId || chatId == message.toId) {
//          await chat.messageList.add(message);
//          await chatsBox.putAt(i, chat);
//
//          await Hive.close();
//          return (CacheSuccess('[CACHE STORED MESSAGE] success'));
//        }
//      }
//      throw CacheException('[CACHE CHAT DOES NOT EXISTS]: $message');
//
//    } catch (e) {
//      await Hive.close();
//      throw CacheException(e.toString());
//    }
//  }
//
//
//  Future<Success> updateMessage(Message updateMessage) async {
//    try {
//      final currentUser = await user;
//      var chatsBox = await Hive.openBox(CHATS_BOX + currentUser.id);
//
//      // Find correct users chatBox for updateMessage
//      for (int i = 0; i < chatsBox.length; i++) {
//        // Get chat
//        final chat = await chatsBox.get(i);
//
//        // chat.user.id == updateMessage.toId : you sent message
//        // chat.user.id == updateMessage.fromId : you received message
//        if (chat.user.id == updateMessage.toId || chat.user.id == updateMessage.fromId) {
//          int messageIndex = 0;
//
//          // Find message to update
//          for (var oldMessage in chat.messageList) {
//            if (oldMessage.dbId == updateMessage.dbId) {
//
//              // Create new updated chat
//              final newMessage = Message(
//                fromId: oldMessage.fromId,
//                toId: oldMessage.toId,
//                content: oldMessage.content,
//                sentAt: oldMessage.sentAt,
//                delivered: true,
//                read: updateMessage.read != null ? true : false,
//                dbId: updateMessage.read != null ? null : updateMessage.dbId,
//              );
//
//              // Save new updated chat over old chat
//              chat.messageList[messageIndex] = newMessage;
//              await chatsBox.putAt(i, chat);
//
//              await Hive.close();
//              return CacheSuccess('[UPDATED MESSAGE]: ${updateMessage.dbId}');
//            }
//            messageIndex++;
//          }
//        }
//      }
//      await Hive.close();
//      return CacheSuccess(
//          '[ERROR UPDATING MESSAGE]: no message found to update ${updateMessage
//              .dbId}');
//    } catch (e) {
//      await Hive.close();
//      return CacheSuccess('[ERROR UPDATING MESSAGE]: ${e.toString()}');
//    }
//  }
//
//
//  @override
//  Future<Success> deleteChat(String chatUserId) async {
////    print('[CACHE DELETE CHAT]: user:$chatUserId');
//    try {
//      // Get current user
//      final currentUser = await user;
//      var chatsBox = await Hive.openBox(CHATS_BOX+currentUser.id);
//
//      // Find users chatBox to be deleted
//      for (int i = 0; i < chatsBox.length; i++) {
//        final chat = await chatsBox.get(i);
//        if (chat.user.id == chatUserId) {
//          // Delete users chat from chatBox
//          await chatsBox.deleteAt(i);
//        }
//      }
//
//      await Hive.close();
//      return CacheSuccess('[CACHE DELETE CHAT]: success');
//
//    } catch (e) {
//      await Hive.close();
//      throw CacheException(e.toString());
//    }
//  }

}
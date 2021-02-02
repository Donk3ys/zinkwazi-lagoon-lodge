import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'item.dart';

part 'menuOrder.g.dart';

@HiveType(typeId: 0)
class MenuOrder {
  MenuOrder({
    @required this.id,
    @required this.dayId,
    @required this.itemList,
    @required this.createdAt,
    @required this.delivered,
    @required this.deliveredAt,
    @required this.prepared,
    @required this.preparedAt,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String dayId;
  @HiveField(2)
  List<Item> itemList;
  @HiveField(3)
  DateTime createdAt;
  @HiveField(4)
  bool delivered;
  @HiveField(5)
  DateTime deliveredAt;
  @HiveField(6)
  bool prepared;
  @HiveField(7)
  DateTime preparedAt;

  int get price {
    int tempPrice = 0;
    for (var item in itemList) {
      tempPrice += item.price;
    }
    return tempPrice;
  }

//  @override
//  String toString() {
//    return "$price $itemList";
//  }

  @override
  String toString() {
    return "$id $dayId $price $itemList";
  }

}
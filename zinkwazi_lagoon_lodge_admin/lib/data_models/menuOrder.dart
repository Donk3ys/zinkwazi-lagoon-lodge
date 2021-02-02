import 'package:flutter/material.dart';

import 'item.dart';

class MenuOrder {
  MenuOrder({
    @required this.id,
    @required this.dayId,
    @required this.itemList,
    @required this.createdAt,
    @required this.prepared,
    @required this.preparedAt,
    @required this.delivered,
    @required this.deliveredAt,
  });

  String id;
  String dayId;
  List<Item> itemList;
  DateTime createdAt;
  bool prepared;
  DateTime preparedAt;
  bool delivered;
  DateTime deliveredAt;

  int get price {
    int tempPrice = 0;
    for (var item in itemList) {
      tempPrice += item.price;
    }
    return tempPrice;
  }


  static List<Item> decodeItemList(List<dynamic> jsonItemList) {
    if (jsonItemList == null ) {
      print('[ERROR] : NO ITEM LIST IN ORDER');
      return [];
    }
    final itemList = jsonItemList.map((jsonItem) => Item.fromJson(jsonItem))
        .toList();
    return itemList;
  }

  factory MenuOrder.fromJson(Map<String, dynamic> json) => MenuOrder(
    id: json["id"].toString(),
    dayId: json["number"].toString(),
    itemList: decodeItemList(json["item_list"]),
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    prepared: json["prepared"],
    preparedAt: json["prepared_at"] != null ? DateTime.parse(json["prepared_at"]) : null,
    delivered: json["delivered"],
    deliveredAt: json["delivered_at"] != null ? DateTime.parse(json["delivered_at"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "number": dayId,
    "price": price,
    "created_at": createdAt.toIso8601String(),
    "prepared": prepared,
    "prepared_at": preparedAt.toIso8601String(),
    "delivered": delivered,
    "delivered_at": deliveredAt.toIso8601String(),
  };

//  @override
//  String toString() {
//    return "$id $dayId $price $createdAt $itemList";
//  }

  @override
  String toString() {
    return "$id $dayId $price $createdAt";
  }

}
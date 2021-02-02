import 'package:flutter/material.dart';

class ItemOption {
  ItemOption({
    @required this.id,
    @required this.itemId,
    @required this.type,
    @required this.name,
    @required this.delete
  });

  final  String id;
  final String itemId;
  String type;
  String name;
  bool delete;


  factory ItemOption.fromJson(Map<String, dynamic> json) => ItemOption(
    id: json["id"].toString(),
    itemId: json["item_id"].toString(),
    name: json["name"],
    type: json["type"],
    delete: false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_id": itemId,
    "name": name,
    "type": type,
    "delete": delete
  };

  @override
  String toString() {
    return '$type:  $name';
  }
}





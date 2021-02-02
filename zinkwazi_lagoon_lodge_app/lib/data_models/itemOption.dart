import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'itemOption.g.dart';

@HiveType(typeId: 2)
class ItemOption {
  ItemOption({
    @required this.id,
    @required this.itemId,
    @required this.type,
    @required this.name,
  });

  @HiveField(0)
  final  String id;
  @HiveField(1)
  final String itemId;
  @HiveField(2)
  String type;
  @HiveField(3)
  String name;


  factory ItemOption.fromJson(Map<String, dynamic> json) => ItemOption(
    id: json["id"].toString(),
    itemId: json["item_id"].toString(),
    name: json["name"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_id": itemId,
    "name": name,
    "type": type,
  };

  @override
  String toString() {
    return '$type: $name';
  }
}





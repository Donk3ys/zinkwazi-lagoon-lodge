import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'itemOption.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  Item({
    @required this.id,
    @required this.name,
    @required this.subheading,
    @required this.type,
    @required this.price,
    @required this.description,
    @required this.optionList,
    @required this.selectedOptionList,
    this.image,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String subheading;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final int price;
  @HiveField(5)
  final String description;
  @HiveField(6)
  final List<ItemOption> optionList;
  @HiveField(7)
  List<ItemOption> selectedOptionList;
  int currentOrderIndex;
  final Image image;


  static List<ItemOption> decodeItemOptionList(List<dynamic> jsonOptionList) {
    if (jsonOptionList == null ) {
      print('[ERROR] : NO OPTIONS LIST IN ITEM');
      return [];
    }
    final optionList = jsonOptionList.map((jsonItemOption) => ItemOption.fromJson(jsonItemOption))
        .toList();
    return optionList;
  }

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"].toString(),
    name: json["name"],
    subheading: json["subheading"] != '' ? json["subheading"] : null,
    type: json["type"],
    price: json["price"],
    description: json["description"] != '' ? json["description"] : null,
    optionList: decodeItemOptionList(json["options"]),
    selectedOptionList: [],
    image: null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "subheading": subheading,
    "type": type,
    "price": price,
    "description": description,
    "options": optionList,
    "selectedOptions": selectedOptionList,
  };

  Item.clone(Item oldItem): this(
      id: oldItem.id,
      name: oldItem.name,
      subheading: oldItem.subheading,
      type: oldItem.type,
      price: oldItem.price,
      description: oldItem.description,
      optionList: oldItem.optionList,
      selectedOptionList: [],
      image: null,
  );

  @override
  String toString() {
    return "$name $type $price";
  }

}
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data_models/itemOption.dart';

class Item extends Equatable {
  Item({
    @required this.id,
    @required this.name,
    @required this.subheading,
    @required this.type,
    @required this.price,
    @required this.description,
    @required this.optionList,
    @required this.selectedOptionList,
    @required this.active,
    this.image,
  });

  final String id;
  final String name;
  final String subheading;
  final String type;
  final int price;
  final String description;
  final List<ItemOption> optionList;
  final List<ItemOption> selectedOptionList;
  final bool active;
  final Image image;



  static List<ItemOption> decodeItemOptionList(List<dynamic> jsonOptionList) {
    if (jsonOptionList == null ) {
//      print('[ERROR] : NO OPTIONS LIST IN ITEM');
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
    selectedOptionList: decodeItemOptionList(json["selectedOptions"]),
    active: json["active"],
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
      "active": active,
    };

    @override
    String toString() {
      return "$name $type $price";
    }

    @override
    List<Object> get props => [id, selectedOptionList];
}





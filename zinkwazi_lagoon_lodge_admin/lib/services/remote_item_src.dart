import 'dart:convert';
import 'package:http/http.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../core/success.dart';
import '../data_models/item.dart';

const ITEM_URL = SERVER_URL + '/api/v1/menu/';

abstract class RemoteItemSourceContract {
//  Future<DateTime> getTimestampDbUpdated();
  Future<List<Item>> getAllItems();
  Future<Item> updatedItem(String jwt, Item updatedItem);
  Future<Item> addItem(String jwt, Item addedItem);
  Future<Item> activateItem(String jwt, String id, bool active);
  Future<Success> deleteItem(String jwt, String id);
}

class RemoteItemSource implements RemoteItemSourceContract {
  final Client http;
  RemoteItemSource(this.http);
  
  @override
  Future<List<Item>> getAllItems() async {
    final url = ITEM_URL + 'items';
    print(url);

    try {
      // Send get request
      final response = await http
          .get(url)
          .timeout(TIME_OUT_DURATION);

      // Log status code
      print('[GET ALL ITEMS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List;

        final itemList = jsonList.map((jsonItem) => Item.fromJson(jsonItem)).toList();

        return itemList;
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }


  @override
  Future<Item> updatedItem(String jwt, Item updatedItem) async {
    final url = ITEM_URL + 'item/update';

    // Create json from updatedItem
    final updatedItemJson = updatedItem.toJson();

    try {
      // Send post request
      final response = await http
          .patch(
            url,
            headers: {"Content-Type": "application/json", "auth-token" : jwt},
            body: json.encode(updatedItemJson)
          ).timeout(TIME_OUT_DURATION
      );

      // Log status code
      print('[UPDATED ITEM] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonItem = json.decode(response.body);

        jsonItem["type"] = null;
        final item = Item.fromJson(jsonItem);

        return item;
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<Item> activateItem(String jwt, String id, bool active) async {
    final url = ITEM_URL + 'item/activate/$id/$active';

    try {
      // Send post request
      final response = await http
          .patch(
          url,
          headers: {"Content-Type": "application/json", "auth-token" : jwt},
      ).timeout(TIME_OUT_DURATION);

      // Log status code
      print('[ACTIVATE ITEM] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonItem = json.decode(response.body);

        jsonItem["type"] = null;
        final item = Item.fromJson(jsonItem);

        return item;
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<Item> addItem(String jwt, Item addedItem) async {
    final url = ITEM_URL + 'item';

    // Create json from updatedItem
    final addedItemJson = addedItem.toJson();

    print(addedItemJson.toString());

    try {
      // Send post request
      final response = await http
          .post(
          url,
          headers: {"Content-Type": "application/json", "auth-token" : jwt},
          body: json.encode(addedItemJson)
      ).timeout(TIME_OUT_DURATION);

      // Log status code
      print('[ADDED ITEM] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
//        var jsonItem = json.decode(response.body);
//
//        jsonItem["type"] = null;
//        final item = Item.fromJson(jsonItem);

        return addedItem;
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  @override
  Future<Success> deleteItem(String jwt, String id) async {
    final url = ITEM_URL + 'item/$id';


    try {
      // Send delete request
      final response = await http
          .delete(url, headers: {"auth-token" : jwt})
          .timeout(TIME_OUT_DURATION);

      // Log status code
      print('[DELETED ITEM] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ServerSuccess();
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

}

//  @override
//  Future<DateTime> getTimestampDbUpdated() async {
//    final url = ITEM_URL + 'items/updated';
//
//    try {
//      // Send get request
//      final response = await http
//          .get(url)
//          .timeout(T_O_DURATION);
//
//      // Log status code
//      print('[GET ITEMS UPDATED TIMESTAMP] Response Code: ${response.statusCode}');
//
//      if (response.statusCode == 200) {
//        var jsonTimestamp = json.decode(response.body);
//        //print('Timestamp $jsonTimestamp');
//        return DateTime.parse(jsonTimestamp["db_updated"]);
//      }
//      throw RemoteDataSourceException(response.body);
//    } catch (error) {
//      throw RemoteDataSourceException(error.toString());
//    }
//  }


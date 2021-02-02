import 'dart:convert';
import 'package:http/http.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../data_models/item.dart';


const ITEM_URL = SERVER_URL + '/api/v1/menu/';

abstract class RemoteItemSourceContract {
  Future<DateTime> getTimestampDbUpdated();
  Future<List<Item>> getAllItems();
}

class RemoteItemSource implements RemoteItemSourceContract {
  final Client http;
  RemoteItemSource(this.http);

  @override
  Future<DateTime> getTimestampDbUpdated() async {
    final url = ITEM_URL + 'items/updated';
    print(url);

    try {
      // Send get request
      final response = await http
          .get(url)
          .timeout(TIME_OUT_DURATION);

      // Log status code
      print('[GET ITEMS UPDATED TIMESTAMP] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonTimestamp = json.decode(response.body);
        print('Timestamp $jsonTimestamp');
        return DateTime.parse(jsonTimestamp["db_updated"]);
      }
      throw RemoteDataSourceException(response.body);
    } catch (error) {
      print(error);
      throw RemoteDataSourceException(error.toString());
    }
  }
  
  @override
  Future<List<Item>> getAllItems() async {
    final url = ITEM_URL + 'items/active';
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
      print(error);
      throw RemoteDataSourceException(error.toString());
    }
  }

}

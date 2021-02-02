import 'package:flutter/material.dart';
import '../data_models/itemOption.dart';
import '../data_models/item.dart';
import '../data_models/itemType.dart';
import '../repositories/items_repo.dart';
import '../services/navigation.dart';
import '../views/snackbar.dart';


enum ItemViewState { Error, Idle, Busy }
enum ItemPageView { Types, Items, AddType, AddItem }

class ItemViewModel extends ChangeNotifier {

  final NavigationServiceContract navigationService;
  final ItemRepository itemRepository;

  ItemViewModel({
    @required this.navigationService,
    @required this.itemRepository,
  });

  List<Item> allItemList = [];
  List<Item> itemList = [];
  List<ItemType> itemTypeList = [];

  String selectedTypeName = '';

  BuildContext context;

  showSnackBar(String message) async {
    Scaffold.of(context).showSnackBar(await InfoSnackBar.create(message));
  }

  // State Management
  ItemViewState _state = ItemViewState.Idle;
  ItemViewState get state => _state;
  void setState(ItemViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // View Management
  ItemPageView _view = ItemPageView.Types;
  ItemPageView get view => _view;
  void setView(ItemPageView viewState) {
    _view = viewState;
    notifyListeners();
  }

//  Future<Image> loadImage(Item item) async {
//    String path = 'assets/${item.name.toLowerCase()}-${item.type.toLowerCase()}.jpeg';
//    return rootBundle.load(path).then((value) {
//      return Image.memory(value.buffer.asUint8List());
//    }).catchError((_) {
//      return null;
//    });
//  }

  Future<void> getMenuItems() async {
    setState(ItemViewState.Busy);

    final failureOrItemList = await itemRepository.getAllItems();
    failureOrItemList.fold(
            (failure) => showSnackBar(failure.toString()),
            (list) async {
              // Sort list by name
              Comparator<Item> itemNameComparator = (a, b) => a.name.compareTo(b.name);
              list.sort(itemNameComparator);

              itemTypeList = [];

              // Create all item type list
              for (var item in list) {
                bool found = false;

                for (var type in itemTypeList) {
                  // If type already in list increment item count
                  if (item.type == type.name) {
                    found = true;
                    type.itemCount++;
                  }
                }

                if (!found) { itemTypeList.add(ItemType(name: item.type, itemCount: 1)); }
              }

//              // Get images from memory
//              int index = 0;
//              for (var item in list) {
//                final image = await loadImage(item);
//                final newItem = Item(
//                    id: item.id,
//                    name: item.name,
//                    subheading: item.subheading,
//                    type: item.type,
//                    price: item.price,
//                    description: item.description,
//                    image: image
//                );
//
//                list[index] = newItem;
//                index++;
//              }

              // Sort item type list in alphabetic order
              Comparator<ItemType> typeNameComparator = (a, b) => a.name.compareTo(b.name);
              itemTypeList.sort(typeNameComparator);

              allItemList = list;
            }
    );

    setState(ItemViewState.Idle);

  }


  Future<void> getTypeItems(String typeName) async {
    itemList.clear();

    // Create item type list
    for (var item in allItemList) {
      if (item.type == typeName) {
        itemList.add(item);
      }
    }

    setState(ItemViewState.Idle);
  }

  Future<void> showItemsPage() async {
    getTypeItems(selectedTypeName);
    setView(ItemPageView.Items);
  }

  Future<Item> updateItem({
    String id,
    String name,
    String subheading,
    String price,
    bool active,
    List<ItemOption> optionList,
    String description,
    }) async {

    // Convert price from string to int
    int convertedPrice;
    try {
      convertedPrice = (double.parse(price) * 100).round();
    } catch (error) {
      print(error);
      print('Price to int parse error');
      return null;
    }

    Item dbItem;
    // Created new item from updated item
    final updatedItem = Item(
        id: id,
        name: name,
        subheading: subheading,
        type: null,
        price: convertedPrice,
        active: active,
        optionList: optionList,
        selectedOptionList: [],
        description: description
    );
    print('Updated item $updatedItem');

    final failureOrItem = await itemRepository.updatedItem(updatedItem);
    await failureOrItem.fold(
            (failure) => showSnackBar(failure.toString()),
            (item) async {
              dbItem = item;
              await getMenuItems();
              showItemsPage();
            }
    );

    await Future.delayed(Duration(seconds: 1), () {});
    setView(ItemPageView.Items);
    return dbItem;
  }


  Future<Item> activateItem({String id, bool active}) async {
    Item dbItem;
    print('Activate item $id');

    final failureOrItem = await itemRepository.activateItem(id, active);
    await failureOrItem.fold(
            (failure) => showSnackBar(failure.toString()),
            (item) async {
          dbItem = item;
          await getMenuItems();
          showItemsPage();
        }
    );

    setView(ItemPageView.Items);
    return dbItem;
  }


  Future<bool> deleteItem(String id) async {
    bool itemDeleted = false;
    final failureOrSuccess = await itemRepository.deleteItem(id);
    await failureOrSuccess.fold(
            (failure) async => showSnackBar(failure.toString()),
            (_) async {
              await getMenuItems();
              showItemsPage();
              itemDeleted = true;
            }
    );

    await Future.delayed(Duration(seconds: 2), () {});
    setView(ItemPageView.Items);
    return itemDeleted;
  }


  Future<bool> addItem({
    String name,
    String subheading,
    String price,
    String description,
  }) async {

    // Convert price from string to int
    int convertedPrice;
    try {
      convertedPrice = (double.parse(price) * 100).round();
    } catch (error) {
      print('Price to int parse error adding new item');
      print(error);
      return false;
    }

    // Created new item from updated item
    final newItem = Item(
        id: null,
        name: name,
        subheading: subheading,
        active: false,
        type: selectedTypeName,
        price: convertedPrice,
        optionList: [],
        selectedOptionList: [],
        description: description);
    print('Added item $newItem');

    bool updatedSuccess = false;
    final failureOrItem = await itemRepository.addItem(newItem);
    await failureOrItem.fold(
            (failure) => showSnackBar(failure.toString()),
            (item) async {
              await getMenuItems();
              showItemsPage();
              updatedSuccess = true;
            }
    );

    await Future.delayed(Duration(seconds: 1), () {});
    setView(ItemPageView.Items);
    return updatedSuccess;
  }

  Future<void> addType(String name) async {

    // Created new item type
    final newItem = ItemType(name: name, itemCount: 0);

    itemTypeList.add(newItem);

    //await Future.delayed(Duration(seconds: 1), () {});
    setView(ItemPageView.Types);
  }

}
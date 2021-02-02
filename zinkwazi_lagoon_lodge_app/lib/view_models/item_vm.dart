import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../core/failure.dart';
import '../data_models/item.dart';
import '../data_models/itemType.dart';
import '../repositories/items_repo.dart';
import '../services/navigation.dart';


enum ItemViewState { Error, Idle, Busy }
enum ItemPageView { Types, Items }

class ItemViewModel extends ChangeNotifier {
  final NavigationServiceContract navigationService;
  final ItemRepository itemRepository;

//  BuildContext pageContext;
  BuildContext scaffoldContext;

  DateTime itemListLastUpdated = DateTime.now();

  ItemViewModel({
    @required this.navigationService,
    @required this.itemRepository,
  });

  List<Item> allItemList = [];
  List<Item> itemList = [];
  List<ItemType> itemTypeList = [];

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


  showSnackBar(String message) async {
    Scaffold.of(scaffoldContext).showSnackBar(SnackBar(content: Text(message)));
//    if (_state == OrderViewState.Error) {}
  }

  Future<bool> _shouldUpdateItems() async {
    bool update = true;
    final failureOrTimestamp = await itemRepository.getTimestampDbUpdated();
    failureOrTimestamp.fold(
            (failure) {
              update =  false;

              // If failed due to being offline
              if (failure is OfflineFailure)  {
                // TODO Set App to offline mode
                showSnackBar(OFFLINE_ERROR_MESSAGE);
                update = false;
              }
            },
            (timestamp) {
              //print('Timestamp VM $timestamp : $itemListLastUpdated');
              if (itemListLastUpdated == timestamp) { update = false; }
              itemListLastUpdated = timestamp;
            }
    );
    return update;
  }


  Future<Image> loadImage(Item item) async {
//    String path = 'assets/${item.name.toLowerCase()}-${item.type.toLowerCase()}.jpeg';
    String path = 'assets/${item.id}.jpeg';
    return rootBundle.load(path).then((value) {
      return Image.memory(value.buffer.asUint8List());
    }).catchError((_) {
      return null;
    });
  }

  Future<void> getMenuItems() async {
    setState(ItemViewState.Busy);

    if (! await _shouldUpdateItems()) {
      setState(ItemViewState.Idle);
      return;
    }

    final failureOrItemList = await itemRepository.getAllItems();
    await failureOrItemList.fold(
            (failure) async {
              // If failed due to being offline
              if (failure is OfflineFailure)  {
                // TODO Set App to offline mode
                showSnackBar(OFFLINE_ERROR_MESSAGE);
              }
            },
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

              // Get images from memory
              int index = 0;
              for (var item in list) {
                final image = await loadImage(item);
                final newItem = Item(
                    id: item.id,
                    name: item.name,
                    subheading: item.subheading,
                    type: item.type,
                    price: item.price,
                    description: item.description,
                    optionList: item.optionList,
                    selectedOptionList: [],
                    image: image
                );

                list[index] = newItem;
                index++;
              }

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
  }

  Future<void> showItemsPage(String typeName) async {
    getTypeItems(typeName);
    setView(ItemPageView.Items);
  }

}
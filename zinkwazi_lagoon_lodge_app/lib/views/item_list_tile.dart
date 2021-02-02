import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_models/itemOption.dart';
import '../core/constants.dart';
import '../data_models/item.dart';
import '../view_models/order_vm.dart';

const IMAGE_WIDTH = 280.0;
//const IMAGE_HEIGHT = 130.0;
const IMAGE_HEIGHT = 190.0;


class ItemListTile extends StatefulWidget {
  final Item item;
  ItemListTile(this.item);

  @override
  _ItemListTileViewState createState() => _ItemListTileViewState();
}

class _ItemListTileViewState extends State<ItemListTile> {
  OrderViewModel orderViewModel;

  List<Item> orderItemList = [];

  Map<String, List<ItemOption>> sortedOptionMap;
  List<dynamic> keyIndex;


  Map<String, List<ItemOption>> itemOptionsMenu() {
    Map<String, List<ItemOption>> sortedOptionMap = {};
    for (var option in widget.item.optionList) {
      // Add option name if type already added to sortedOptionList
      if (sortedOptionMap.containsKey(option.type)) {
        sortedOptionMap[option.type].add(option);
      } else {
        // Add option type and name to sortedOptionList
        sortedOptionMap[option.type] = [option];
      }
    }
    return sortedOptionMap;
  }

  @override
  void initState() {
    super.initState();
    // Get orderViewModel
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    // Sort options into groups
    sortedOptionMap = itemOptionsMenu();
    keyIndex = sortedOptionMap.keys.toList();

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
        builder: (context, orderVM, child) => SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: widget.item.image != null
                    ? const EdgeInsets.only(top: 100.0, left: 10.0)
                    : const EdgeInsets.all(0.0),
                child: Container(
                  width: ITEM_WIDTH,
                  child: Card(
                    color: CARD_COLOR,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          widget.item.image != null
                              ? SizedBox(height: 100.0,)
                              : SizedBox(height: 8.0,),
                          Container(
                            child: Text(widget.item.name,
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          widget.item.subheading != null
                              ? SizedBox(height: 4.0,)
                              : SizedBox(),
                          widget.item.subheading != null
                              ? Text(widget.item.subheading, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: TEXT_COLOR))
                              : SizedBox(),
                          widget.item.description != null
                              ? SizedBox(height: 12.0,)
                              : SizedBox(),
                          widget.item.description != null
                              ? Text(widget.item.description)
                              : SizedBox(),
                          SizedBox(height: 16.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('R ${widget.item.price / 100}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  orderVM.getNumberOfItemsInOrder(widget.item) == 0
                                      ? SizedBox()
                                      : RawMaterialButton(
                                      fillColor: BUTTON_COLOR,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(8.0),
                                      constraints: BoxConstraints(),
                                      child: Icon(Icons.remove, color: REMOVE_COLOR,),
                                      onPressed: () {
                                        orderVM.removeItemFromOrder(widget.item);
                                      }
                                  ),
                                  SizedBox(width: 8),
                                  orderVM.getNumberOfItemsInOrder(widget.item) == 0
                                      ? SizedBox()
                                      : Text('${orderVM.getNumberOfItemsInOrder(widget.item)}x' ,
                                      style: TextStyle(fontSize: 16,  color: TEXT_COLOR)),
                                  SizedBox(width: 8),
                                  orderVM.getNumberOfItemsInOrder(widget.item) == 0
                                      ? Text('Add to order', style: TextStyle(color: ADD_COLOR),)
                                      : SizedBox(),
                                  orderVM.getNumberOfItemsInOrder(widget.item) == 0 ? SizedBox(width: 8) : SizedBox(),
                                  RawMaterialButton(
                                      fillColor: BUTTON_COLOR,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(8.0),
                                      constraints: BoxConstraints(),
                                      child: Icon(Icons.add, color: ADD_COLOR,),
                                      onPressed: () {
                                        // Deep copy of Item
                                        Item item = Item.clone(widget.item);

                                        // Set initial options for item
                                        sortedOptionMap.forEach((key, value) {
//                                  print('$key : ${value[0]}');
                                          // Add first option for each type
                                          item.selectedOptionList.add(value[0]);
                                        });

                                        orderVM.addItemToOrder(item);
                                      }
                                  )
                                ],
                              ),
                            ],
                          ),
                          widget.item.optionList.isNotEmpty
                              ? orderItemsListView()
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              widget.item.image != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 60.0),
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        child: Image(
                          image: AssetImage('assets/${widget.item.id}.jpeg'),
                         // height: 130.0,
                          height: IMAGE_HEIGHT,
                          width: IMAGE_WIDTH,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            ],
          ),
        ),
    );
  }


// List of all current items in Order
  ListView orderItemsListView() {
    // Populate orderItemList
    orderItemList = [];
    for (var orderItem in orderViewModel.currentOrder.itemList) {
//      print('${orderItem.currentOrderIndex}: ${orderItem.name}: ${orderItem.selectedOptionList.toString()}');
      if (orderItem.id == widget.item.id) { orderItemList.add(orderItem); }
    }

    return ListView.builder(
        reverse: true,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: orderItemList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
//                  color: Colors.red,
                    height: 54,
                    width: ITEM_OPTION_LIST_WIDTH,
                    child: optionListView(orderItemList[index])
                ),
                Column(
                  children: [
                    Text('Options ${sortedOptionMap.length}x', style: TextStyle(fontSize: 10.0, color: TEXT_COLOR),),
                    RawMaterialButton(
                        fillColor: BUTTON_COLOR,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(4.0),
                        constraints: BoxConstraints(),
                        child: Icon(Icons.remove, color: REMOVE_COLOR,),
                        onPressed: () {
                         orderViewModel.removeItemFromOrder(orderItemList[index]);
                        }
                    )
                  ],
                ),
              ],
            )
          );
        }
    );
  }

  // Individual list of item options ie: each option list for added item to Order
  ListView optionListView(Item item) {
    return ListView.builder(
        shrinkWrap: true,
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: sortedOptionMap.length,
        itemBuilder: (context, index) {
          return OptionListTile(
              item: item,
              optionList: sortedOptionMap[keyIndex[index]],
          );
        }
    );
  }
}

// Tile for each Item option
class OptionListTile extends StatefulWidget {
  final Item item;
  final List<ItemOption> optionList;

  OptionListTile({@required this.item, @required this.optionList});

  @override
  _OptionListTileViewState createState() => _OptionListTileViewState();
}

class _OptionListTileViewState extends State<OptionListTile> {
  OrderViewModel orderViewModel;
  ItemOption selectedOption;

  @override
  void initState() {
    super.initState();
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    for(var option in widget.item.selectedOptionList) {
      if (option.type == widget.optionList[0].type) {
        selectedOption =  option;
        break;
      }
    }

    return PopupMenuButton(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: BUTTON_COLOR,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.optionList[0].type, style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 4.0,),
            Text(selectedOption.name, overflow: TextOverflow.ellipsis,),
          ],
        ),
      ),
    ),
      initialValue: widget.optionList[0],
      onCanceled: () {
        print('You have not chosen anything');
      },
      tooltip: 'Select an option',
      onSelected: (option) => orderViewModel.updateItemOption(widget.item, option),
      itemBuilder: (BuildContext context) {
        return widget.optionList.map((ItemOption option) {
          return PopupMenuItem(
            value: option,
            child: Text(option.name),
          );
        }).toList();
      },
    );
  }
}
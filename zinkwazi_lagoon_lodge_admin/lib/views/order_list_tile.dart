import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/order_vm.dart';
import '../core/constants.dart';
import '../data_models/item.dart';
import '../data_models/menuOrder.dart';

class OrderListTile extends StatefulWidget {
  final MenuOrder order;

  OrderListTile(this.order);

  @override
  _OrderListTileState createState() => _OrderListTileState();
}

class _OrderListTileState extends State<OrderListTile> {
  Map<Item, int> currentOrderItemMap = {};
  bool updatedSuccessfully = true;

  void createOrderItemMap() {
    // Add items to map with number of
    final eq = ListEquality().equals;
    for (var item in widget.order.itemList) {
      Item itemToUpdate;
      currentOrderItemMap.forEach((itemFromMap, numberOfItems) {
        if (item.id == itemFromMap.id
            && eq(item.selectedOptionList, itemFromMap.selectedOptionList)) {
          itemToUpdate = itemFromMap;
        }
      });
      if (itemToUpdate == null) {
        currentOrderItemMap[item] = 1;
      } else {
        currentOrderItemMap[itemToUpdate]++;
      }
    }
  }

  Widget orderLog(String header, DateTime timestamp) {
    final timeFormatted = timestamp != null
        ? DateFormat('hh:mm a E d MMM yyyy').format(timestamp)
        : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: TextStyle(fontSize: 12,)),
        SizedBox(height: 2.0,),
        Text(timeFormatted, style: TextStyle(fontSize: 10, color: TEXT_COLOR, fontStyle: FontStyle.italic)),
      ],
    );
  }

//  String getDeliveredDuration() {
//    final duration = widget.order.deliveredAt.difference(widget.order.createdAt);
//    format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
//    //print('createdAt: ${widget.order.createdAt} : deliveredAt: ${widget.order.deliveredAt} : duration: ${duration.inMinutes}');
//
//    return '${format(duration)}';
//  }

  @override
  void initState() {
    super.initState();
    createOrderItemMap();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
              elevation: 4.0,
              color: CARD_COLOR,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                height: widget.order.delivered
                    ? 150.0 + currentOrderItemMap.length * 58.0
                    : 200.0 + currentOrderItemMap.length * 58.0,
                width: 500.0,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Order Number', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                                  Text('Total', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                                ],
                              ),
                              SizedBox(height: 6.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  //Text('Items ${widget.order.itemList.length}', style: TextStyle(fontSize: 16, color: TEXT_COLOR)),
                                  Text('# ${widget.order.dayId}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                                  Text('R ${widget.order.price / 100}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: BACKGROUND_COLOR, thickness: 0.5,),
//                  SizedBox(height: 12.0,),
                    Expanded(child: itemsListView()),
                    Divider(color: BACKGROUND_COLOR, thickness: 0.5,),
                    Consumer<OrderViewModel>(
                      builder: (context, orderVM, child) => Row(
                        children: [
                        // Placed Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              orderLog('Placed', widget.order.createdAt),
                              SizedBox(height: 8.0,),
                              !widget.order.delivered
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(updatedSuccessfully ? 'Cancel' : 'Failed', style: TextStyle(color: updatedSuccessfully ? REMOVE_COLOR : REMOVE_COLOR),),
                                  SizedBox(width: 8),
                                  RawMaterialButton(
                                    fillColor: BUTTON_COLOR,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(8.0),
                                    constraints: BoxConstraints(),
                                    child: Icon(Icons.close, color: REMOVE_COLOR,),
                                    onPressed: () => null,
                                  )
                                ],
                              ) : SizedBox()
                            ],
                          ),
                        ),
                        // Prepared Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              orderLog('Prepared', widget.order.preparedAt),
                              SizedBox(height: 8.0,),
                              !widget.order.prepared
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(updatedSuccessfully ? 'Prepared' : 'Failed', style: TextStyle(color: updatedSuccessfully ? WARNING_COLOR : REMOVE_COLOR),),
                                  SizedBox(width: 8),
                                  RawMaterialButton(
                                    fillColor: BUTTON_COLOR,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(8.0),
                                    constraints: BoxConstraints(),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: WARNING_COLOR,
                                    ),
                                    onPressed: () => orderVM.preparedOrder(widget.order.id),
                                  )
                                ],
                              ) : !widget.order.delivered ? SizedBox(height: 48.0,) : SizedBox(),
                            ],
                          ),
                        ),
                        // Delivered Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              orderLog('Delivered', widget.order.deliveredAt),
                              SizedBox(height: 8.0,),
                              !widget.order.delivered
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(updatedSuccessfully ? 'Delivered' : 'Failed', style: TextStyle(color: updatedSuccessfully ? ADD_COLOR : REMOVE_COLOR),),
                                  SizedBox(width: 8.0,),
                                  RawMaterialButton(
                                    fillColor: BUTTON_COLOR,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(8.0),
                                    constraints: BoxConstraints(),
                                    child: Icon(
                                      Icons.check,
                                      color: ADD_COLOR,
                                    ),
                                    onPressed: () => orderVM.deliveredOrder(widget.order.id),
                                  )
                                ],
                              ) : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  ListView itemsListView() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
        itemCount: currentOrderItemMap.length,
        itemBuilder: (context, index) {

        final _numberOfItems = currentOrderItemMap.values.elementAt(index);
        final _item = currentOrderItemMap.keys.elementAt(index);

        String _itemName;
        _numberOfItems == 1
            ? _itemName = _item.name
            : _itemName = '${_numberOfItems}x ${_item.name}';

        int _price = _item.price * _numberOfItems;

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_itemName,
                        style: TextStyle(fontSize: 16)),
                    Text(_item.type, style: TextStyle(fontSize: 12, color: TEXT_COLOR),),
                    _item.selectedOptionList.isNotEmpty
                        ? Text(_item.selectedOptionList.toString().substring(1, _item.selectedOptionList.toString().length - 1 ),
                            style: TextStyle(fontSize: 12, color: TEXT_COLOR),
                          )
                        : SizedBox(),
                  ],
                ),
                Text('R ${_price / 100}', style: TextStyle(color: TEXT_COLOR),),
              ],
            ),
          );
        }
    );
  }
}
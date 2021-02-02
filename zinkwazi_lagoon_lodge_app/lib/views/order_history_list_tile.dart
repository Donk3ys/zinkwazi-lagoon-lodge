import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../data_models/item.dart';
import '../data_models/menuOrder.dart';

class OrderHistoryListTile extends StatefulWidget {
  final MenuOrder order;

  OrderHistoryListTile(this.order);

  @override
  _OrderHistoryListTileState createState() => _OrderHistoryListTileState();
}

class _OrderHistoryListTileState extends State<OrderHistoryListTile> with SingleTickerProviderStateMixin {
  Map<Item, int> currentOrderItemMap = {};
  AnimationController _animationController;
  Animation _animation;
  bool showPlaceAt = false;

  Color getShadowColor() {
    if (widget.order.prepared) { return Colors.green[300]; }
    else { return Colors.lightBlueAccent[100]; }
  }

  Widget orderLog(Icon icon, String header, DateTime timestamp) {
    final timeFormatted = timestamp != null
        ? DateFormat('hh:mm a E d MMM yyyy').format(timestamp)
        : '-';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 12.0,),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              SizedBox(width: 12.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(header, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 2.0,),
                  Text(timeFormatted, style: TextStyle(fontSize: 10, color: TEXT_COLOR, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, color: TEXT_COLOR, size: 12.0,),
        SizedBox(width: 12.0,),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation =  Tween(begin: 8.0,end: 18.0).animate(_animationController)..addListener((){
      setState(() {

      });
    });

    createOrderItemMap();

    widget.order.delivered || widget.order.prepared ? showPlaceAt = false : showPlaceAt = true;

    }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
              elevation: widget.order.delivered ? 0.0 : _animation.value,
              shadowColor: widget.order.delivered ? CARD_COLOR : getShadowColor(),
              color: CARD_COLOR,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 300.0,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Order Number', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                            SizedBox(height: 4.0,),
                            Text('# ${widget.order.dayId}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            //orderLog('Placed',  widget.order.createdAt),
                            Text('Total', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                            SizedBox(height: 4.0,),
                            Text('R ${widget.order.price / 100}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0,),
                    Divider(),
//                    Expanded(child: itemsListView()),
                    itemsListView(),
                    Divider(),
                    SizedBox(height: 8.0,),
                    orderLog(Icon(Icons.watch_later, color: ACCENT_COLOR,), 'Placed',  widget.order.createdAt),
                    SizedBox(height: 8.0,),
                    orderLog(Icon(Icons.fastfood, color: ADD_COLOR,), 'Ready',  widget.order.preparedAt),
                    SizedBox(height: 8.0,),
                    orderLog(Icon(Icons.check_circle, color: TEXT_COLOR,), 'Delivered',  widget.order.deliveredAt),
                  ],
                ),
              ),
      ),
    );
  }

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

  ListView itemsListView() {
    return ListView.builder(
        shrinkWrap: true,
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
                    Container(
                      width: 200.0,
                      child: Text(_itemName,
                          style: TextStyle(fontSize: 16)),
                    ),
                    Text(_item.type,
                      style: TextStyle(fontSize: 12, color: TEXT_COLOR),),
                    _item.selectedOptionList.isNotEmpty
                        ? Text(_item.selectedOptionList.toString().substring(1, _item.selectedOptionList.toString().length - 1 ),
                      style: TextStyle(fontSize: 8, color: TEXT_COLOR),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
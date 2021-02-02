import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view_models/order_vm.dart';
import '../data_models/item.dart';
import '../data_models/menuOrder.dart';
import '../core/constants.dart';

class PreparedOrderPage extends StatelessWidget {
  final MenuOrder preparedOrder;
  final OrderViewModel orderViewModel;

  PreparedOrderPage(this.preparedOrder, this.orderViewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        elevation: 0.0,
        title: Image(
          image: AssetImage('assets/zinkwazi_logo.png'),
          height: 52,
          fit: BoxFit.fitWidth,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Order Ready', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Order Number', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                    SizedBox(height: 4.0,),
                    Text('# ${preparedOrder.dayId}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //orderLog('Placed',  widget.order.createdAt),
                    Text('Total', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                    SizedBox(height: 4.0,),
                    Text('R ${preparedOrder.price / 100}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.0,),
            Divider(),
            Expanded(child: itemsListView()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('hh:mm a E d MMM yyyy').format(preparedOrder.preparedAt),
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: TEXT_COLOR),
                ),
                Row(
                  children: [
                    Text('Okay', style: TextStyle(color: ADD_COLOR),),
                    SizedBox(width: 8),
                    RawMaterialButton(
                      fillColor: BUTTON_COLOR,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8.0),
                      constraints: BoxConstraints(),
                      child: Icon(Icons.check, color: ADD_COLOR,),
                      onPressed: () {
                        orderViewModel.showingPreparedPage = false;
                        Navigator.pop(context);
                      } ,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Item list
  ListView itemsListView() {
    Map<Item, int> currentOrderItemMap = {};
    // Add items to map with number of
    final eq = ListEquality().equals;
    for (var item in preparedOrder.itemList) {
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
                    Container(
                      width: 200.0,
                      child: Text(_itemName,
                          style: TextStyle(fontSize: 16)),
                    ),
                    Text(_item.type,
                      style: TextStyle(fontSize: 12, color: TEXT_COLOR),),
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

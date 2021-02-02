import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../data_models/item.dart';
import '../view_models/order_vm.dart';
import '../views/current_order_list_tile.dart';
import '../views/current_order_tile.dart';
import '../views/order_history_list_tile.dart';


class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with WidgetsBindingObserver {
  OrderViewModel orderViewModel;

  @override
  void initState() {
    super.initState();
    // Get orderViewModel
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    // Add observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Run once build complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (orderViewModel.currentOrder.itemList.isNotEmpty) { orderViewModel.setView(OrderPageView.CurrentOrder); }
      orderViewModel.getOrderHistory();
    });

//  @override // class - with WidgetsBindingObserver + init & dispose observers
//  Future<void> didChangeAppLifecycleState(final AppLifecycleState state) async {
//    if (state == AppLifecycleState.resumed) {
//    }
//  }
  }

  @override
  Widget build(BuildContext context) {
    orderViewModel.context = context;

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () =>
                orderViewModel.navigationService.itemPage(context)),
        title: Image(
          image: AssetImage('assets/zinkwazi_logo.png'),
          height: 52,
          fit: BoxFit.fitWidth,
        ),
        centerTitle: true,
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderVM, child) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                orderVM.currentOrder.itemList.isNotEmpty
                    ? Expanded(
                      child: Column(
                        children: <Widget>[
                          FlatButton(
                              child: Text('Current Order', style: TextStyle(fontSize: 18)),
                              onPressed: () => orderVM.setView(OrderPageView.CurrentOrder)
                          ),
                          Container(height: 2.0, width: double.infinity,
                            color: orderVM.view == OrderPageView.CurrentOrder
                              ? ADD_COLOR
                              : BACKGROUND_COLOR
                          ),
                        ],
                      ),
                      )
                    : SizedBox(),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                          child: Text('Orders', style: TextStyle(fontSize: 18)),
                          onPressed: () => orderVM.setView(OrderPageView.OrderHistory)
                      ),
                      orderVM.currentOrder.itemList.isNotEmpty ? Container(height: 2.0, width: double.infinity,
                          color: orderVM.view == OrderPageView.OrderHistory
                              ? ADD_COLOR
                              : BACKGROUND_COLOR
                      ) : SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Expanded(
                child: orderVM.view == OrderPageView.CurrentOrder
                    ? itemsForOrderListView()
                    : orderVM.orderHistoryList.isNotEmpty
                      ? orderHistoryListView()
                      : Center(child: Text('Your order history is empty'))
            ),
            SizedBox(height: 8.0),
            orderVM.currentOrder.itemList.isNotEmpty && orderVM.view == OrderPageView.CurrentOrder
              ? GestureDetector(
                child: CurrentOrderTile('Place Order', orderVM.currentOrder.itemList.length, orderVM.currentOrder.price),
                  //onTap: () => orderVM.placeOrder('paymentId'),
                  onTap: () => orderVM.navigateToPaymentPage(),
            )
              : SizedBox(),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  ListView itemsForOrderListView() {
    Map<Item, int> currentOrderItemMap = {};

    // Add items to map with number of
    final eq = ListEquality().equals;
    for (var item in orderViewModel.currentOrder.itemList) {
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
//      print('${item.name} : ${item.selectedOptionList}');
//      print(currentOrderItemMap);
    }

    return ListView.builder(
        itemCount: currentOrderItemMap.length,
        itemBuilder: (context, index) {
          return Center(
            child: OrderItemListTile(currentOrderItemMap.keys.elementAt(index),
                currentOrderItemMap.values.elementAt(index)),
          );
        });
  }

// TODO maybe implement ListView for  order history tile
//  ListView orderHistoryListView() {
//    return ListView.builder(
//        scrollDirection: Axis.horizontal,
//        itemCount: orderViewModel.orderHistoryList.length,
//        itemBuilder: (context, index) {
//          return Padding(
//            padding: const EdgeInsets.all(12.0),
//            child: OrderHistoryListTile(orderViewModel.orderHistoryList[index]),
//          );
//        }
//    );
//  }

  StaggeredGridView orderHistoryListView() {
    return StaggeredGridView.countBuilder(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 2,
      itemCount: orderViewModel.orderHistoryList.length,
      itemBuilder: (BuildContext context, int index) => Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: OrderHistoryListTile(orderViewModel.orderHistoryList[index]),
          ),
      staggeredTileBuilder: (int index) =>
      StaggeredTile.extent(
          orderViewModel.orderHistoryList[index].itemList.length >= 2
              ? 2
              : orderViewModel.orderHistoryList[index].delivered ? 1 : 2,
          350
      ),
    );
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Disposing OrderPage');
    super.dispose();
  }
}
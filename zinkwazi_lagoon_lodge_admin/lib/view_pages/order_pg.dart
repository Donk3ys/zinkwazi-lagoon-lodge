import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/order_vm.dart';
import '../views/order_list_tile.dart';

const BEGIN_COLOR = ADD_COLOR;
const END_COLOR = ACCENT_COLOR;

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  OrderViewModel orderViewModel;

  static DateTime beginDate = DateTime.now();
  static DateTime endDate =
      DateTime(beginDate.year, beginDate.month, beginDate.day + 1);

  Future<void> selectBeginDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: beginDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));

    if (picked != null && picked != beginDate) {
      setState(() {
        beginDate = picked;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: endDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Get orderViewModel
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    orderViewModel.initSocket();

    // Run once build complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //orderViewModel.startCurrentOrderBackgroundWorker();
      //orderViewModel.getCurrentOrderList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Consumer<OrderViewModel>(
        builder: (context, orderVM, child) =>
            Builder(builder: (BuildContext context) {
          orderViewModel.context = context;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200.0,
                    color: orderVM.view == OrderPageView.CurrentOrder
                        ? CARD_COLOR
                        : BACKGROUND_COLOR,
                    child: FlatButton(
                        child: Text('Current Orders',
                            style: TextStyle(fontSize: 14)),
                        onPressed: () {
                          orderVM.setView(OrderPageView.CurrentOrder);
                          //orderVM.startCurrentOrderBackgroundWorker();
                        }),
                  ),
                  Container(
                    width: 200.0,
                    color: orderVM.view == OrderPageView.OrderHistory
                        ? CARD_COLOR
                        : BACKGROUND_COLOR,
                    child: FlatButton(
                      child:
                          Text('Order History', style: TextStyle(fontSize: 14)),
                      onPressed: () {
                        orderVM.setView(OrderPageView.OrderHistory);
                        orderVM.getOrdersByDate(beginDate, endDate);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              orderVM.view == OrderPageView.OrderHistory
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Begin', style: TextStyle(color: BEGIN_COLOR)),
                        SizedBox(
                          width: 4.0,
                        ),
                        RawMaterialButton(
                          fillColor: BUTTON_COLOR,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(8.0),
                          constraints: BoxConstraints(),
                          child: Icon(
                            Icons.alarm,
                            color: BEGIN_COLOR,
                          ),
                          onPressed: () async {
                            await selectBeginDate(context);
                            orderVM.getOrdersByDate(beginDate, endDate);
                          },
                        ),
                        SizedBox(
                          width: 4.0,
                        ),
                        Text(beginDate.toIso8601String().substring(0, 10),
                            style: TextStyle(color: BEGIN_COLOR)),
                        SizedBox(
                          width: 42.0,
                        ),
                        Text('End', style: TextStyle(color: END_COLOR)),
                        SizedBox(
                          width: 4.0,
                        ),
                        RawMaterialButton(
                          fillColor: BUTTON_COLOR,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(8.0),
                          constraints: BoxConstraints(),
                          child: Icon(
                            Icons.alarm,
                            color: END_COLOR,
                          ),
                          onPressed: () async {
                            await selectEndDate(context);
                            orderVM.getOrdersByDate(beginDate, endDate);
                          },
                        ),
                        SizedBox(
                          width: 4.0,
                        ),
                        Text(endDate.toIso8601String().substring(0, 10),
                            style: TextStyle(color: END_COLOR)),
                      ],
                    )
                  : SizedBox(),
              Expanded(
                  child: orderVM.view == OrderPageView.CurrentOrder
                      ? orderVM.currentOrderList.isNotEmpty
                          ? currentOrdersListView()
                          : Center(child: Text('No orders currently placed'))
                      : orderVM.orderHistoryList.isNotEmpty
                          ? orderHistoryListView()
                          : Center(
                              child: Text('No orders between selected dates'))),
              SizedBox(height: 12.0),
            ],
          );
        }),
      ),
    );
  }

  ListView currentOrdersListView() {
    return ListView.builder(
//        scrollDirection: Axis.horizontal,
        itemCount: orderViewModel.currentOrderList.length,
        itemBuilder: (context, index) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrderListTile(orderViewModel.currentOrderList[index]),
          ));
        });
  }

  ListView orderHistoryListView() {
    return ListView.builder(
//        scrollDirection: Axis.horizontal,
        itemCount: orderViewModel.orderHistoryList.length,
        itemBuilder: (context, index) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrderListTile(orderViewModel.orderHistoryList[index]),
          ));
        });
  }
}

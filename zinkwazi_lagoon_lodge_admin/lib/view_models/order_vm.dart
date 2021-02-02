import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zinkwazilagoonlodgeadmin/views/snackbar.dart';
import '../data_models/menuOrder.dart';
import '../repositories/order_repo.dart';
import '../services/navigation.dart';

enum OrderViewState { Error, Idle, Busy }
enum OrderPageView { CurrentOrder, OrderHistory }

class OrderViewModel extends ChangeNotifier {

  final NavigationServiceContract navigationService;
  final OrderRepository orderRepository;

  OrderViewModel({
    @required this.navigationService,
    @required this.orderRepository
  }) {
    orderStream();
  }

  StreamSubscription orderStreamSub;

  List<MenuOrder> currentOrderList = [];
  List<MenuOrder> orderHistoryList = [];

  BuildContext context;

  showSnackBar(String message) async {
    Scaffold.of(context).showSnackBar(await InfoSnackBar.create(message));
  }

  // State Management
  OrderViewState _state = OrderViewState.Idle;
  OrderViewState get state => _state;
  void setState(OrderViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // View Management
  OrderPageView _view = OrderPageView.CurrentOrder;
  OrderPageView get view => _view;
  void setView(OrderPageView viewState) {
    _view = viewState;
    notifyListeners();
  }


  Future<void> getOrdersByDate(DateTime beginDate, DateTime endDate) async {
    setState(OrderViewState.Busy);

    final failureOrOrderList = await orderRepository.getOrderListByDate(beginDate, endDate);
    failureOrOrderList.fold(
            (failure) => showSnackBar(failure.toString()),
            (orderList) => orderHistoryList = orderList
    );

    // Sort order list by date
    orderHistoryList = orderHistoryList.reversed.toList();
//    Comparator<MenuOrder> createdAtComparator = (a, b) => a.createdAt.compareTo(b.createdAt);
//    orderHistoryList.sort(createdAtComparator);

    // Get all current orders waiting to be processed
    currentOrderList = [];
    for (var order in orderHistoryList) {
      if (!order.delivered) { currentOrderList.add(order); }
    }

    setState(OrderViewState.Idle);
  }

  Future<void> deliveredOrder(String id) async {
    setState(OrderViewState.Busy);

    await orderRepository.deliveredOrder(id);
    //final failureOrOrderList = await orderRepository.deliveredOrder(id);
    // failureOrOrderList.fold(
    //         (failure) => print(failure.toString()),
    //         (success) => null//getCurrentOrderList()
    // );
    setState(OrderViewState.Idle);
  }

  Future<void> preparedOrder(String id) async {
    setState(OrderViewState.Busy);

    await orderRepository.preparedOrder(id);
    //final failureOrOrderList = await orderRepository.preparedOrder(id);
    // failureOrOrderList.fold(
    //         (failure) => print(failure.toString()),
    //         (success) => null//getCurrentOrderList()
    // );
    setState(OrderViewState.Idle);
  }

  // Socket
  Future initSocket() async {
    orderRepository.initSocket();
  }

  Future orderStream() async {
    orderStreamSub = orderRepository.orderStream().listen((orderList) async {
      //print("ORDER STREAM CALLED: " + orderList.toString());
      List<MenuOrder> tempOrderList = orderList;

      // Sort order list by date
      tempOrderList = tempOrderList.reversed.toList();

      // Get all current orders waiting to be processed
      currentOrderList = [];
      for (var order in tempOrderList) {
        if (!order.delivered) { currentOrderList.add(order); }
      }

      setState(OrderViewState.Idle);
    });
  }

  Future closeSockets() async {
    orderRepository.closeSockets();
  }

  Future closeStreams() async {
    orderRepository.closeStreams();
    if (orderStreamSub != null) { orderStreamSub.cancel(); }
  }

  @override
  void dispose() {
    closeSockets();
    closeStreams();
    super.dispose();
  }

}
import 'dart:async';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/failure.dart';
import '../data_models/item.dart';
import '../data_models/itemOption.dart';
import '../data_models/menuOrder.dart';
import '../repositories/order_repo.dart';
import '../services/navigation.dart';
import '../services/notification.dart';

enum OrderViewState { Error, Idle, Busy }
enum OrderPageView { CurrentOrder, OrderHistory, OrderPrepared }

const Duration INIT_ORDER_CHECK_DELAY = Duration(seconds: 15);
const Duration ORDER_CHECK_DELAY = Duration(seconds: 15);

class OrderViewModel extends ChangeNotifier {
  final NotificationService notificationService;
  final NavigationServiceContract navigationService;
  final OrderRepository orderRepository;

  OrderViewModel({
    @required this.notificationService,
    @required this.navigationService,
    @required this.orderRepository
  }){
    orderRepository.initStreams();
    Future.delayed(Duration(seconds: 5), () {
      newConnectionStream();
      checkOrderStatusStream();
      checkWorkingOrdersStatus(update: true);
    });
  }

  BuildContext context;
  bool showingPreparedPage = false;
  List<String> _showedPreparedPage = [];

  StreamSubscription newConnectionStreamSub;
  StreamSubscription orderStreamSub;

  bool placingOrder = false;


  MenuOrder currentOrder = MenuOrder(id: null, dayId: null, itemList: [], createdAt: null,
      prepared: false, preparedAt: null, deliveredAt: null, delivered: false);
  List<MenuOrder> orderHistoryList = [];

  // State Management
  OrderViewState _state = OrderViewState.Idle;
  OrderViewState get state => _state;
  void setState(OrderViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // View Management
  OrderPageView _view = OrderPageView.OrderHistory;
  OrderPageView get view => _view;
  void setView(OrderPageView viewState) {
    _view = viewState;
    notifyListeners();
  }

  showSnackBar(String message) async {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
//    if (_state == OrderViewState.Error) {}
  }


  Future<void> addItemToOrder(Item item) async {
    if(currentOrder.itemList.isEmpty) { item.currentOrderIndex = 0; }
    else { item.currentOrderIndex = currentOrder.itemList.last.currentOrderIndex + 1; }
//    print('Added item index: ${item.currentOrderIndex}');
    currentOrder.itemList.add(item);
    //print(currentOrder.toString());

    setState(OrderViewState.Idle);
  }

  Future<void> removeItemFromOrder(Item item) async {
    // Remove first item
    // if no items match remove first instance of item type
    if (item.currentOrderIndex == null) {
      for (int i = 0; i < currentOrder.itemList.length; i++ ) {
        if (item.id == currentOrder.itemList[i].id) {
          currentOrder.itemList.removeAt(i);
          break;
        }
      }
    } else {
      // Remove specific item
      // Check if any items == item to remove
      for (int i = 0; i < currentOrder.itemList.length; i++ ) {
        if (item.currentOrderIndex == currentOrder.itemList[i].currentOrderIndex) {
          currentOrder.itemList.removeAt(i);
          break;
        }
      }
    }

    //print(currentOrder.toString());
    setState(OrderViewState.Idle);
    // Check if order is empty
    if (currentOrder.itemList.isEmpty) { setView(OrderPageView.OrderHistory); }
  }

  Future<void> updateItemOption(Item item, ItemOption option) async {
    // Find current item in order list
    for (var orderItem in currentOrder.itemList) {
      if (item.currentOrderIndex == orderItem.currentOrderIndex) {
        // Update selected option for specific type
        for (int i = 0; i < orderItem.selectedOptionList.length; i++){
          if (option.type == orderItem.selectedOptionList[i].type) {
            orderItem.selectedOptionList[i] = option;
            break;
          }
        }
//        print(orderItem.selectedOptionList);
        break;
      }
    }

    //print(currentOrder.toString());
    setState(OrderViewState.Idle);
  }

  int getNumberOfItemsInOrder(Item item) {
    int numberOfItems = 0;
    for (var orderItem in currentOrder.itemList) {
      if (orderItem.id == item.id) { numberOfItems++; }
    }
    return numberOfItems;
  }

  Future<void> placeOrder(String paymentId) async {
    placingOrder = true;

    if (currentOrder.itemList.isEmpty) { return; }
    setState(OrderViewState.Busy);

    final failureOrMenuOrder = await orderRepository.placeOrder(paymentId, currentOrder);
    failureOrMenuOrder.fold(
            (failure) {
              print(failure.toString());

              // If offline
              if (failure is OfflineFailure) {
                // TODO Set AuthViewModel to offline
                showSnackBar(OFFLINE_ERROR_MESSAGE);
              }
            },
            (placedOrder) {
              getOrderHistory();
              // Start checking order status
              // TODO Add an order to check with socket
              //Future.delayed(INIT_ORDER_CHECK_DELAY, () => checkOrderStatus());
              currentOrder = MenuOrder(id: null, dayId: null, itemList: [], createdAt: null, prepared: false, preparedAt: null, deliveredAt: null, delivered: false);
              setView(OrderPageView.OrderHistory);
            }
    );

    placingOrder = false;
    setState(OrderViewState.Idle);
  }

  Future<void> getOrderHistory() async {
    setState(OrderViewState.Busy);

    final failureOrOrderHistory = await orderRepository.getOrderHistory();
    failureOrOrderHistory.fold(
            (failure) => print(failure.toString()),
            (orderHistory) {
              orderHistoryList = orderHistory;

              // Sort list by date
              Comparator<MenuOrder> orderDateComparator = (a, b) => a.createdAt.compareTo(b.createdAt);
              orderHistoryList.sort(orderDateComparator);

              orderHistoryList = orderHistoryList.reversed.toList();
            }
    );

    setState(OrderViewState.Idle);
  }

  // Get all orders that haven't been delivered yet
  Future<int> checkWorkingOrdersStatus({@required bool update}) async {
    print("CHECKING WORKING ORDER STATUSES");
    // Get order history to re-populate order memory
    await getOrderHistory();

    final orderList = await orderRepository.getOrdersToStatusCheck();
    if (orderList.isNotEmpty && update) {
      for (var order in orderList) {
        await Future.delayed(Duration(seconds: 5), () =>  checkOrderStatus(order));
      }
    } else if (orderList.isEmpty) {
      closeSocket();
    }
    print("ORDER LIST TO CHECK: ${orderList.length}");
    return orderList.length;
  }

  // check status when app restart for any updated orders
  Future<void> checkOrderStatus(MenuOrder order) async {
  final failureOrSuccess = await orderRepository.checkOrderStatus(order);
  await failureOrSuccess.fold(
          (failure) async {
            print(failure.toString());
            // TODO Check for unexpected failure -> stop checking status
            if (failure.toString() == "500") { return; }

            setState(OrderViewState.Error);

            // If failed due to being offline
            if (failure is OfflineFailure) {
              // TODO Set AuthViewModel to offline
              await Future.delayed(ORDER_CHECK_DELAY, () => checkOrderStatus(order));
              showSnackBar(OFFLINE_ERROR_MESSAGE);
            }
            // TODO remove snackbar
            //showSnackBar(failure.toString());
            await Future.delayed(ORDER_CHECK_DELAY, () => checkOrderStatus(order));
          },
          (updatedOrder) async {
            // If order has only been prepared and prepared page hasn't been shown for updated order id
            if (updatedOrder.prepared && !updatedOrder.delivered && !_showedPreparedPage.any((orderId) => orderId == updatedOrder.id)) {
              // Add order id to list of ids for prepared page shown already
              _showedPreparedPage.add(updatedOrder.id);

              // Show notification
              await notificationService.showPreparedNotification(
                order: updatedOrder,
              );

              // Navigate to Prepared order page
              navigationService.preparedPage(context, updatedOrder, this);

              // Check if delivered
              checkOrderStatus(updatedOrder);
            }

            // get updated orders from local storage
            await getOrderHistory();
            setState(OrderViewState.Idle);

            // // Check if order has been delivered -> if not then try again
            // if (!updatedOrder.delivered) {
            //   checkOrderStatus(updatedOrder);
            // }
            // Check if anymore orders waiting for updates
            if (await checkWorkingOrdersStatus(update: false) <= 0) { closeSocket(); }
          }
    );
  }


  // Socket
  Future newConnectionStream() async {
    orderStreamSub = orderRepository.newConnectionStream()
        .listen((hasConnection) async {
      if (hasConnection && ! placingOrder) { checkWorkingOrdersStatus(update: true); }
    });
  }

  Future checkOrderStatusStream() async {
    orderStreamSub = orderRepository.orderStream()
        .listen((updatedOrder) async {
          // If order has only been prepared and prepared page hasn't been shown for updated order id
          if (updatedOrder.prepared && !updatedOrder.delivered && !_showedPreparedPage.any((orderId) => orderId == updatedOrder.id)) {
            // Add order id to list of ids for prepared page shown already
            _showedPreparedPage.add(updatedOrder.id);

            // Show notification
            await notificationService.showPreparedNotification(
              order: updatedOrder,
            );

            // Navigate to Prepared order page
            navigationService.preparedPage(context, updatedOrder, this);
          }

          // get updated orders from local storage
          await getOrderHistory();
          setState(OrderViewState.Idle);
          // Check if anymore orders waiting for updates
          if (await checkWorkingOrdersStatus(update: false) <= 0) { closeSocket(); }
    });
  }


  // Routes
  Future<void> navigateToOrderPage() async {
    navigationService.orderPage(context, this);
  }

  Future<void> navigateToPaymentPage() async {
    navigationService.paymentPage(context, this);
  }

  Future closeStreams() async {
    orderRepository.closeStreams();
    if (newConnectionStreamSub != null) { newConnectionStreamSub.cancel(); }
    if (orderStreamSub != null) { orderStreamSub.cancel(); }
  }

  Future closeSocket() async {
    orderRepository.closeSocket();
  }

  @override
  void dispose() {
    closeStreams();
    closeSocket();
    super.dispose();
  }

  // TODO Offline Handler
//  Future _getUserWhenInternetConnected() async {
//    inOfflineMode = true;
//    while (inOfflineMode) {
//      await Future.delayed(Duration(seconds: 2), () {});
//      await authRepository.isConnected()
//          ? inOfflineMode = false
//          : inOfflineMode = true;
//    }
//    await getCurrentUser();
//  }

}





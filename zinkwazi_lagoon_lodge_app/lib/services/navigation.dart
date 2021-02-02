import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_pages/payment_pg.dart';
import '../data_models/menuOrder.dart';
import '../view_pages/items_pg.dart';
import '../view_pages/prepared_pg.dart';
import '../view_models/order_vm.dart';
import '../view_pages/order_pg.dart';


abstract class NavigationServiceContract {
  Future<void> itemPage(BuildContext context);
  Future<void> orderPage(BuildContext context, OrderViewModel viewModel);
  Future<void> preparedPage(BuildContext context, MenuOrder order, OrderViewModel viewModel);
  Future<void> paymentPage(BuildContext context, OrderViewModel viewModel);

}

class NavigationService implements NavigationServiceContract {

  @override
  Future<void> itemPage(BuildContext context) async {
    print('[NAVIGATE TO ITEM PAGE]');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ItemPage()
        )
    );
  }

  @override
  Future<void> orderPage(BuildContext context, OrderViewModel viewModel) async {
    print('[NAVIGATE TO ORDER PAGE]');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: OrderPage(),
        ),
      ),
    );
  }

  @override
  Future<void> preparedPage(BuildContext context, MenuOrder order, OrderViewModel viewModel) async {
    print('[NAVIGATE TO PREPARED PAGE]');
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PreparedOrderPage(order, viewModel)
    ));
  }

  @override
  Future<void> paymentPage(BuildContext context, OrderViewModel viewModel) async {
    print('[NAVIGATE TO PAYMENT PAGE]');
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: PaymentPage(),
        ),
      ),
    );
  }


// TODO add change notifier provider to class params
//  @override
//  Future<void> orderPage(BuildContext context, OrderViewModel viewModel) async {
//    print('[NAVIGATE TO ORDER PAGE]');
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (context) => ChangeNotifierProvider.value(
//          value: viewModel,
//          child: OrderPage(),
//        ),
//      ),
//    );
//  }

}
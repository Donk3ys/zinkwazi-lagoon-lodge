import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_pages/login_pg.dart';
import '../view_models/order_vm.dart';
import '../view_pages/order_pg.dart';
import '../view_pages/items_pg.dart';


abstract class NavigationServiceContract {
  Future<void> loginPage(BuildContext context);
  Future<void> itemPage(BuildContext context);
  Future<void> orderPage(BuildContext context, OrderViewModel viewModel);
}

class NavigationService implements NavigationServiceContract {
  @override
  Future<void> loginPage(BuildContext context) async {
    print('[NAVIGATE TO HOME PAGE]');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()
        )
    );
  }

  @override
  Future<void> itemPage(BuildContext context) async {
    print('[NAVIGATE TO HOME PAGE]');
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: OrderPage(),
        ),
      ),
    );
  }

}
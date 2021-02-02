import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service_locator.dart';
import 'view_models/item_vm.dart';
import 'view_models/order_vm.dart';
import 'view_pages/items_pg.dart';

import 'core/constants.dart';

void main() {
  initInjector();
  runApp(App());
}

class App extends StatelessWidget {
  final itemViewModel = sl<ItemViewModel>();
  final orderViewModel = sl<OrderViewModel>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemViewModel>(
            create: (context) => itemViewModel),
        ChangeNotifierProvider<OrderViewModel>(
            create: (context) => orderViewModel),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
            primaryColor: BACKGROUND_COLOR,
            backgroundColor: BACKGROUND_COLOR,
            accentColor: ACCENT_COLOR,
            visualDensity: VisualDensity.adaptivePlatformDensity
        ),
        home: ItemPage(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'service_locator.dart';
import 'view_models/auth_vm.dart';
import 'view_models/item_vm.dart';
import 'view_models/order_vm.dart';
import 'view_models/user_vm.dart';
import 'view_pages/index_pg.dart';


void main() async {
  // GetIt
  await initInjector();
  runApp(App());
}

class App extends StatelessWidget {
  final authViewModel = sl<AuthViewModel>();
  final itemViewModel = sl<ItemViewModel>();
  final orderViewModel = sl<OrderViewModel>();
  final userViewModel = sl<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
            create: (context) => authViewModel),
        ChangeNotifierProvider<ItemViewModel>(
            create: (context) => itemViewModel),
        ChangeNotifierProvider<OrderViewModel>(
            create: (context) => orderViewModel),
        ChangeNotifierProvider<UserViewModel>(
            create: (context) => userViewModel),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          primaryColor: BACKGROUND_COLOR,
          backgroundColor: BACKGROUND_COLOR,
          accentColor: ACCENT_COLOR,
          visualDensity: VisualDensity.adaptivePlatformDensity
      ),
        home: SafeArea(child: IndexPage()),
      ),
    );
  }
}

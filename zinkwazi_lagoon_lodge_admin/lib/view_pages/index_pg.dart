import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../view_models/auth_vm.dart';
import '../view_models/item_vm.dart';
import '../view_models/order_vm.dart';
import '../view_models/user_vm.dart';
import '../view_pages/items_pg.dart';
import '../view_pages/login_pg.dart';
import '../view_pages/order_pg.dart';
import '../view_pages/users_pg.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  AuthViewModel authViewModel;
  ItemViewModel itemViewModel;
  OrderViewModel orderViewModel;
  UserViewModel userViewModel;

  Widget getPage() {
    if (authViewModel.currentUser == null) {
      return LoginPage();
    } else if (authViewModel.view == AuthPageView.Item) {
      return ItemPage();
    } else if (authViewModel.view == AuthPageView.Order) {
      return OrderPage();
    } else if (authViewModel.view == AuthPageView.User) {
      return UserPage(authViewModel.currentUser);
    }
    return LoginPage();
  }

  Widget getItems() {
    if (authViewModel.currentUser != null &&
        authViewModel.currentUser.role != "kitchen") {
      return FlatButton(
        child: Text('Items'),
        onPressed: () => {
          authViewModel.setView(AuthPageView.Item),
          itemViewModel.setView(ItemPageView.Types),
        },
      );
    }
    return SizedBox();
  }

  Widget getOrders() {
    if (authViewModel.currentUser != null) {
      return FlatButton(
        child: Text('Orders'),
        onPressed: () => authViewModel.setView(AuthPageView.Order),
      );
    }
    return SizedBox();
  }

  Widget getUsers() {
    if (authViewModel.currentUser != null &&
        authViewModel.currentUser.role != "kitchen") {
      return FlatButton(
        child: Text('Users'),
        onPressed: () => {
          authViewModel.setView(AuthPageView.User),
          userViewModel.setView(UserPageView.Users),
        },
      );
    }
    return SizedBox();
  }

  @override
  void initState() {
    super.initState();
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CARD_COLOR,
      body: Builder(builder: (BuildContext context) {
        authViewModel.context = context;
        return Consumer<AuthViewModel>(
          builder: (context, authVM, child) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20.0,
                        height: 60.0,
                      ),
                      Image(
                        image: AssetImage('zinkwazi_logo.png'),
                        width: 100,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 50.0,
                      ),
                      getOrders(),
                      SizedBox(
                        width: 30.0,
                      ),
                      getItems(),
                      SizedBox(
                        width: 30.0,
                      ),
                      getUsers(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(authVM.currentUser != null
                          ? authVM.currentUser.username
                          : ""),
                      SizedBox(
                        width: 20.0,
                      ),
                      authVM.currentUser != null
                          ? FlatButton(
                        child: Text('Logout'),
                        onPressed: () => {
                          authVM.setView(AuthPageView.AuthLogin),
                          authVM.logout(),
                        },
                      )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
              Expanded(child: getPage()),
            ],
          ),
        );
      }),
    );
  }
}

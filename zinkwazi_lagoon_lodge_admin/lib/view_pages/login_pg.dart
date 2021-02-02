import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service_locator.dart';
import '../view_models/auth_vm.dart';
import '../views/form_controls_login.dart';
import '../views/loading_view.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final authViewModel = sl<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
        builder: (context, authVM, child) => Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400.0,
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Text('login',
                      style: TextStyle(fontSize: 40.0, ), //color: TEXT_COLOR
                    ),
                  ),
                  LoginFormController(),
                  authVM.state == AuthViewState.Busy ? LoadWidget() : SizedBox()
                ],
              ),
            ),
          ),
        ),
    );
  }
}

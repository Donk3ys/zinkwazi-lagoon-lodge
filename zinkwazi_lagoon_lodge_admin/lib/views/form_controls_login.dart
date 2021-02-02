import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_vm.dart';

const String FIELD_NOT_ENTERED_MESSAGE = 'Field cannot be left empty';

class LoginFormController extends StatefulWidget {
  @override
  _LoginFormControllerState createState() => _LoginFormControllerState();
}


class _LoginFormControllerState extends State<LoginFormController> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, child) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              validator: (value) {
                return value.isEmpty ? FIELD_NOT_ENTERED_MESSAGE : null;
              },
              style: TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                  hintText: 'username',
//                  hintStyle: TextStyle(fontSize: 18.0, color: TEXT_COLOR),
//                  helperStyle: TextStyle(fontSize: 18.0, color: TEXT_COLOR),
                  prefixIcon: const Icon(
                    Icons.tag_faces_outlined,
//                    color: TEXT_COLOR,
                  ),
//                  enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: TEXT_CONTENT_COLOR),
//                  ),
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: LIKE_COLOR),
//                  ),
              ),
              controller: _usernameController,
            ),
            SizedBox(height: 10.0,),
            TextFormField(
              validator: (value) {
                return value.isEmpty ? FIELD_NOT_ENTERED_MESSAGE : null;
              },
              style: TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                  hintText: 'password',
//                  hintStyle: TextStyle(fontSize: 18.0, color: TEXT_COLOR),
//                  counterStyle: TextStyle(color: TEXT_COLOR),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
//                    color: TEXT_COLOR,
                  ),
//                  labelStyle: TextStyle(color: TEXT_COLOR),
//                  enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: TEXT_CONTENT_COLOR),
//                  ),
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: LIKE_COLOR),
//                  ),
              ),
              controller: _passwordController,
            ),
            SizedBox(
              height: 50.0,
            ),
            Builder(
              builder: (context) => RaisedButton(
//                color: TEXT_TILE_COLOR,
                child: Text('LETS GO', ), //style: TextStyle(color: TILE_DIV_LINE_COLOR)
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                   await authVM.loginUser(
                     _usernameController.text.trim(),
                     _passwordController.text.trim(),
                   );
                   // await authVM.loginUser(
                   //   "donk3y",
                   //   "1234",
                   // );

                   _passwordController.clear();
//                    authVM.showSnackBar(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

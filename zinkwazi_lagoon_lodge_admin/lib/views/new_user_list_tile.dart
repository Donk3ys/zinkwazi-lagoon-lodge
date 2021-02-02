import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_models/user.dart';
import '../core/constants.dart';
import '../views/loading_view.dart';
import '../view_models/user_vm.dart';

const USERNAME_NOT_ENTERED_MESSAGE = 'Name required';
const PASSWORD_NOT_ENTERED_MESSAGE = 'Password required';
const PASSWORD_NOT_LONG_ENOUGH_MESSAGE = 'Password must be at least 6 characters long';


class NewUserListTile extends StatefulWidget {
  @override
  _NewUserListTile createState() => _NewUserListTile();
}

class _NewUserListTile extends State<NewUserListTile> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "kitchen";
  List<String> roles = ["Kitchen"];

  bool updating = false;
  bool updatedSuccessfully = true;

  double getTextSize(String text) {
    if (text.length < 18) { return 24.0; }
    else { return 20.0; }
  }

  Future<void> addUser(UserViewModel userVM)  async {
    if (formKey.currentState.validate()) {
      setState(() {
        updating = true;
      });

      await userVM.addUser(
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
          email: emailController.text.trim(),
          role: role,
      );

      updating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userVM, child) => Container(
        width: 600.0,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 36.0),
          elevation: 12.0,
          color: CARD_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          validator: (name) {
                            return name.isEmpty ? USERNAME_NOT_ENTERED_MESSAGE : null;
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
//                          border: InputBorder.none,
                              hintText: 'Username'
                          ),
                          controller: usernameController,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
//                          border: InputBorder.none,
                              hintText: 'Email'
                          ),
                          controller: emailController,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(updatedSuccessfully ? 'Add' : 'Failed', style: TextStyle(color: updatedSuccessfully ? ADD_COLOR : REMOVE_COLOR),),
                      SizedBox(width: 8),
                      updating
                          ? LoadWidget()
                          : RawMaterialButton(
                        elevation: 2.0,
                        fillColor: BUTTON_COLOR,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8.0),
                        constraints: BoxConstraints(),
                        child: Icon(
                          Icons.add,
                          color: ADD_COLOR,
                        ),
                        onPressed: () => addUser(userVM),
                      ),
                      SizedBox(width: 8),
                      Text('Cancel', style: TextStyle(color: REMOVE_COLOR),),
                      SizedBox(width: 8),
                      RawMaterialButton(
                        elevation: 2.0,
                        fillColor: BUTTON_COLOR,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8.0),
                        constraints: BoxConstraints(),
                        child: Icon(
                          Icons.close,
                          color: REMOVE_COLOR,
                        ),
                        onPressed: () => userVM.setView(UserPageView.Users),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          validator: (name) {
                            String failMessage;
                            if (name.isEmpty) { failMessage = PASSWORD_NOT_ENTERED_MESSAGE; }
                            else if (name.length <= 5) { failMessage = PASSWORD_NOT_LONG_ENOUGH_MESSAGE; }
                            return failMessage;
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
//                          border: InputBorder.none,
                              hintText: 'Password'
                          ),
                          controller: passwordController,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(child: roleSelector(userVM.currentUser)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuButton roleSelector(User user) {
    if (user.role == "super") { roles = ["kitchen", "admin", "super"]; }

    return PopupMenuButton(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: BUTTON_COLOR,
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(role,  textAlign: TextAlign.center,),
        ),
      ),
      initialValue: role,
      onCanceled: () {
        print('You have not chosen anything');
      },
      tooltip: 'Select users role',
      onSelected: (option) {
        print(option);
        setState(() { role = option; });
      },
      itemBuilder: (BuildContext context) {
        return roles.map((String option) {
          return PopupMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList();
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

}
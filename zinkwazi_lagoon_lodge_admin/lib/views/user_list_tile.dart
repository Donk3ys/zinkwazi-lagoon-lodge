import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../data_models/user.dart';
import '../view_models/user_vm.dart';
import 'loading_view.dart';

const TEXT_SIZE = 16.0;
const LABEL_SIZE = 10.0;

const PASSWORD_NOT_ENTERED_MESSAGE = 'Password required';
const PASSWORD_NOT_LONG_ENOUGH_MESSAGE = 'Password must be at least 6 characters long';

class UserListTile extends StatefulWidget {
  final User user;
  UserListTile(this.user);

  @override
  _UserListTile createState() => _UserListTile();
}

class _UserListTile extends State<UserListTile> {
  UserViewModel userViewModel;

  final formKey = GlobalKey<FormState>();
  final newPasswordTextController = TextEditingController();
  bool editing = false;
  bool updating = false;
  bool updatedSuccessfully = true;

  @override
  void initState() {
    super.initState();
    // Get view model provider
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
  }

  Future<void> updatePassword(UserViewModel userVM)  async {
    if (formKey.currentState.validate()) {
      setState(() { updating = true; });

      await userVM.updatePassword(widget.user, newPasswordTextController.text.trim());
      updating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userVM, child) => Container(
        width: 800.0,
        child: Card(
          elevation: 6.0,
          color: CARD_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.user.id.toString(),
                        style:
                            TextStyle(fontSize: TEXT_SIZE, color: TEXT_COLOR),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        child: Text(
                          widget.user.active ? "Active" : "Hidden",
                          style: TextStyle(
                              fontSize: TEXT_SIZE,
                              color: widget.user.active
                                  ? ADD_COLOR
                                  : REMOVE_COLOR),
                        ),
                        onTap: () => userViewModel.activateUser(
                            id: widget.user.id, active: !widget.user.active),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.user.username,
                        style: TextStyle(fontSize: TEXT_SIZE),
                        //style: TextStyle(fontSize: TEXT_SIZE, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Text(
                        widget.user.email != null ? widget.user.email : '',
                        style: TextStyle(fontSize: TEXT_SIZE),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.user.role,
                        style: TextStyle(fontSize: TEXT_SIZE),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: RawMaterialButton(
                        elevation: 2.0,
                        fillColor: BUTTON_COLOR,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8.0),
                        constraints: BoxConstraints(),
                        child: Icon(
                          Icons.lock_outline,
                          color: ADD_COLOR,
                        ),
                        onPressed: () => setState(() { editing = true; }),
                      ),
                    ),
                  ],
                ),
                editing ? Row(
                  children: [
                    Expanded(
                      child: Form(
                          key: formKey,
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
                                hintText: 'New Password'
                            ),
                            controller: newPasswordTextController,
                          ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(updatedSuccessfully ? 'Update' : 'Failed', style: TextStyle(color: updatedSuccessfully ? ADD_COLOR : REMOVE_COLOR),),
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
                        Icons.check,
                        color: ADD_COLOR,
                      ),
                      onPressed: () => updatePassword(userVM),
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
                      onPressed: () => setState(() { editing = false; }),
                    ),
                  ],
                ) : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    newPasswordTextController.dispose();
    super.dispose();
  }
}

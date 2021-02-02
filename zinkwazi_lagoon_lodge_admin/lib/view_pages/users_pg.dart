import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../data_models/user.dart';
import '../view_models/user_vm.dart';
import '../views/new_user_list_tile.dart';
import '../views/user_list_tile.dart';

class UserPage extends StatefulWidget {
  final User currentUser;
  UserPage(this.currentUser);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  UserViewModel userViewModel;

  @override
  void initState() {
    super.initState();
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.currentUser = widget.currentUser;
    userViewModel.context = context;

    // Run once build complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userViewModel.getUsersList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userVM, child) => Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ACCENT_COLOR,
          child: Icon(Icons.add),
          onPressed: () => userVM.setView(UserPageView.AddUser),
          //onPressed: () => userVM.showSnackBar(),
        ),
        body: Builder(builder: (BuildContext context) {
          userViewModel.context = context;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 12.0,
              ),
              SizedBox(
                width: 800,
                child: Card(
                  elevation: 0.0,
                  color: BACKGROUND_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Id',
                            style: TextStyle(
                                fontSize: LABEL_SIZE, color: TEXT_COLOR),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            style: TextStyle(
                                fontSize: LABEL_SIZE, color: TEXT_COLOR),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Username',
                            style: TextStyle(
                                fontSize: LABEL_SIZE, color: TEXT_COLOR),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Email',
                            style: TextStyle(
                                fontSize: LABEL_SIZE, color: TEXT_COLOR),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Role',
                            style: TextStyle(
                                fontSize: LABEL_SIZE, color: TEXT_COLOR),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                                fontSize: LABEL_SIZE, color: TEXT_COLOR),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Expanded(child: usersListView()),
              userVM.view == UserPageView.AddUser
                  ? NewUserListTile()
                  : SizedBox(),
              SizedBox(
                height: 2.0,
              )
            ],
          );
        }),
      ),
    );
  }

  ListView usersListView() {
    return ListView.builder(
        itemCount: userViewModel.allUsersList.length,
        itemBuilder: (context, index) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: UserListTile(userViewModel.allUsersList[index]),
          ));
        });
  }
}

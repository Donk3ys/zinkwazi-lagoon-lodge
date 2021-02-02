import 'package:flutter/material.dart';
import '../data_models/user.dart';
import '../repositories/auth_repo.dart';
import '../services/navigation.dart';
import '../views/snackbar.dart';


enum UserViewState { Error, Idle, Busy }
enum UserPageView { Users, AddUser }

class UserViewModel extends ChangeNotifier {

  final NavigationServiceContract navigationService;
  final AuthRepositoryContract authRepository;

  UserViewModel({
    @required this.navigationService,
    @required this.authRepository,
  });

  BuildContext context;
  User currentUser;

  List<User> allUsersList = [];


  // State Management
  UserViewState _state = UserViewState.Idle;
  UserViewState get state => _state;
  void setState(UserViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // View Management
  UserPageView _view = UserPageView.Users;
  UserPageView get view => _view;
  void setView(UserPageView viewState) {
    _view = viewState;
    notifyListeners();
  }

  showSnackBar(String message) async {
    Scaffold.of(context).showSnackBar(await InfoSnackBar.create(message));
  }


  Future<void> getUsersList() async {
    setState(UserViewState.Busy);

    final failureOrUserList = await authRepository.getUsers(currentUser.role);
    failureOrUserList.fold(
            (failure) => showSnackBar(failure.toString()),
            (userList) {
              // Sort list by name
              Comparator<User> userNameComparator = (a, b) => a.username.compareTo(b.username);
              userList.sort(userNameComparator);

              allUsersList = userList;
            }
    );

    setState(UserViewState.Idle);
  }

  Future<void> addUser({@required String username, @required String password, @required String role, String email}) async {
    setState(UserViewState.Busy);

    final newUser = User(id: null, username: username, password: password, role: role, email: email, active: false);

    final failureOrSuccess = await authRepository.register(newUser);
    failureOrSuccess.fold(
            (failure) => showSnackBar(failure.toString()),
            (userList) {
              getUsersList();
              setView(UserPageView.Users);
            }
    );

    setState(UserViewState.Idle);
  }

  Future<User> activateUser({String id, bool active}) async {
    User dbUser;
    print('Activate user $id');

    final failureOrUser = await authRepository.activateUser(id, active);
    await failureOrUser.fold(
            (failure) => null,
            (user) async {
              dbUser = user;
              await getUsersList();
        }
    );

    setView(UserPageView.Users);
    return dbUser;
  }

  Future<void> updatePassword(User user, String newPassword) async {

    final failureOrSuccess = await authRepository.updatePassword(user.id, newPassword);
    failureOrSuccess.fold(
            (failure) => showSnackBar(failure.toString()),
            (success) {
              getUsersList();
              setView(UserPageView.Users);
              showSnackBar("Password Update Successful");
            }
    );

    setState(UserViewState.Idle);
  }

}
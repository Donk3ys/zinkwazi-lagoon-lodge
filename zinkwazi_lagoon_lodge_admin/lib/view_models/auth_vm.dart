import 'package:flutter/material.dart';

import '../data_models/user.dart';
import '../repositories/auth_repo.dart';
import '../services/navigation.dart';
import '../views/snackbar.dart';


enum AuthPageView { AuthLogin, Item, Order, User}
enum AuthViewState { Idle, Busy, Error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepositoryContract authRepository;
  final NavigationServiceContract navigationService;

  // Constructor
  AuthViewModel({
    @required this.authRepository,
    @required this.navigationService,
  });

  User currentUser;
  BuildContext context;

  showSnackBar(String message) async {
    Scaffold.of(context).showSnackBar(await InfoSnackBar.create(message));
  }

  // View Management
  AuthPageView _view = AuthPageView.AuthLogin;
  AuthPageView get view => _view;
  void setView(AuthPageView view) {
    _view = view;
    print("SETTING AUTH VIEW PAGE: $_view");
    notifyListeners();
  }

  AuthViewState _state = AuthViewState.Idle;
  AuthViewState get state => _state;
  void setState(AuthViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  Future loginUser(String username, String password) async {
    setState(AuthViewState.Busy);

    final failureOrUser = await authRepository.login(username, password);
    failureOrUser.fold(
        (failure) {
          print(failure.toString());
          showSnackBar(failure.toString());
          setState(AuthViewState.Error);
        },
            (user) {
          currentUser = user;
          setView(AuthPageView.Order);
          setState(AuthViewState.Idle);
        }
    );
  }

  Future logout() async {
    setState(AuthViewState.Busy);

    final failureOrString = await authRepository.logout();
    failureOrString.fold(
        (failure) {
          print(failure.toString());
          showSnackBar(failure.toString());
        },
        (success) {
          currentUser = null;
        }
    );

    setState(AuthViewState.Idle);
  }
}
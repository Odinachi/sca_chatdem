import 'dart:io';

import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/services/firebase_services.dart';
import 'package:flutter/cupertino.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseService firebaseService;

  AuthenticationProvider({required this.firebaseService});

  bool loading = false;

  File? _profileImage;

  File? get profileImage => _profileImage;
  UserModel? userModel;

  void setImage(File img) {
    _profileImage = img;
    notifyListeners();
  }

  Future<void> logout() async {
    await firebaseService.logout();
  }

  Future<({bool? loggedIn, String? error})> login(
      {required String email, required String password}) async {
    loading = true;
    notifyListeners();
    final login = await firebaseService.login(email: email, password: password);
    if (login.user != null) {
      loading = false;
      userModel = login.user;
      notifyListeners();
      return (loggedIn: true, error: null);
    } else {
      loading = false;
      notifyListeners();
      return (loggedIn: null, error: login.error);
    }
  }

  Future<({bool? registered, String? error})> register(
      {required String email,
      required String password,
      required String name}) async {
    loading = true;
    notifyListeners();
    final login = await firebaseService.register(
      name: name,
      email: email,
      password: password,
      img: profileImage!,
    );
    if (login.user != null) {
      userModel = login.user;

      loading = false;
      notifyListeners();

      return (registered: true, error: null);
    } else {
      loading = false;
      notifyListeners();
      return (registered: null, error: login.error);
    }
  }
}

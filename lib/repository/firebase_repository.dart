import 'package:chatdem/services/firebase_services.dart';

class FirebaseRepo {
  final firebaseService = FirebaseService();

  Future<({String? error, bool? loggedIn})> login(
      {required String email, required String password}) async {
    return await firebaseService.login(email: email, password: password);
  }

  Future<({String? error, bool? registered})> register(
      {required String email, required String password}) async {
    return await firebaseService.register(email: email, password: password);
  }
}

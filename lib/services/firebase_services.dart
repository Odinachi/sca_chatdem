import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final auth = FirebaseAuth.instance;

  Future<({bool? loggedIn, String? error})> login(
      {required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await auth.currentUser?.reload();
      return (loggedIn: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (loggedIn: null, error: e.message);
    } catch (e) {
      return (loggedIn: null, error: e.toString());
    }
  }

  Future<({bool? registered, String? error})> register(
      {required String email, required String password}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await auth.currentUser?.reload();

      return (registered: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (registered: null, error: e.message);
    } catch (e) {
      return (registered: null, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
    } catch (_) {}
  }
}

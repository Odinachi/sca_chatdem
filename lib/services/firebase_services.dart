import 'dart:io';
import 'dart:math';

import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FirebaseService {
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final fireStore = FirebaseFirestore.instance;

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
      {required String email,
      required String password,
      required String name,
      required File img}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await auth.currentUser?.reload();

      await fireStore.collection("user").doc(auth.currentUser?.uid).set(
            UserModel(
                    uid: auth.currentUser?.uid,
                    name: name,
                    img: imgs[Random().nextInt(imgs.length)])
                .toJson(),
          );

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

  Future<String?> uploadImg(File img) async {
    try {
      final storageRef = storage.ref();

      final imgRef = storageRef.child(
          "${auth.currentUser?.uid}/${DateTime.now().millisecondsSinceEpoch}${p.extension(img.path)}");

      final upload = await imgRef.putFile(img);
      if (upload.state == TaskState.success) {
        return await imgRef.getDownloadURL();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<({ChatModel? model, String? error})> createChatModel(
      ChatModel model) async {
    try {
      model = model.copyWith(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          time: DateTime.now());

      await fireStore.collection("chats").doc(model.id).set(model.toJson());
      return (model: model, error: null);
    } catch (e) {
      return (model: null, error: e.toString());
    }
  }

  Future<List<ChatModel>?> getChatRooms() async {
    try {
      final getAllRooms = await fireStore.collection("chats").get();

      return List<ChatModel>.from(
          getAllRooms.docs.map((e) => ChatModel.fromJson(e.data())));
    } catch (_) {
      return [];
    }
  }
}

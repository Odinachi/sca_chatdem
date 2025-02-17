import 'dart:io';
import 'dart:math';

import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/features/home/models/message_model.dart';
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

  Future<({UserModel? user, String? error})> login(
      {required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await auth.currentUser?.reload();
      return (
        user: await getUser(uid: auth.currentUser?.uid ?? ""),
        error: null
      );
    } on FirebaseAuthException catch (e) {
      return (user: null, error: e.message);
    } catch (e) {
      return (user: null, error: e.toString());
    }
  }

  Future<UserModel?> getUser({String? uid}) async {
    try {
      final get = await fireStore
          .collection("users")
          .doc(uid ?? auth.currentUser?.uid)
          .get();

      if (get.exists) {
        return UserModel.fromJson(get.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<({UserModel? user, String? error})> register(
      {required String email,
      required String password,
      required String name,
      required File img}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await auth.currentUser?.reload();

      await fireStore.collection("users").doc(auth.currentUser?.uid).set(
            UserModel(
                    uid: auth.currentUser?.uid,
                    name: name,
                    img: imgs[Random().nextInt(imgs.length)])
                .toJson(),
          );

      return (
        user: await getUser(uid: auth.currentUser?.uid ?? ""),
        error: null
      );
    } on FirebaseAuthException catch (e) {
      return (user: null, error: e.message);
    } catch (e) {
      return (user: null, error: e.toString());
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
      final getAllRooms = await fireStore
          .collection("chats")
          .where(
            "isGroup",
            isEqualTo: true,
          )
          .get();

      return List<ChatModel>.from(
          getAllRooms.docs.map((e) => ChatModel.fromJson(e.data())));
    } catch (_) {
      return [];
    }
  }

  Future<List<ChatModel>?> getDms() async {
    try {
      final getAllRooms = await fireStore
          .collection("chats")
          .where(
            "isGroup",
            isEqualTo: false,
          )
          .where("participants",
              arrayContainsAny: [auth.currentUser?.uid]).get();

      return List<ChatModel>.from(getAllRooms.docs
          .map((e) => ChatModel.fromJson(e.data()).copyWith(convoId: e.id)));
    } catch (_) {
      return [];
    }
  }

  Future<bool?> sendMessage(
      {String? roomId,
      String? convoId,
      String? recipientName,
      String? recipientImg,
      required bool isNewMsg,
      required MessageModel msgModel,
      List<UserModel>? users}) async {
    try {
      final model = msgModel.copyWith(seen: [auth.currentUser?.uid ?? ""]);

      String? lastMsgId;
      await fireStore
          .collection("chats")
          .doc(roomId ?? convoId)
          .collection("messages")
          .add(model.toJson())
          .then((e) {
        lastMsgId = e.id;
      });
      await fireStore.collection('chats').doc(roomId ?? convoId).set({
        "lastMsg": msgModel.msg,
        "lastMsgId": lastMsgId,
        "lastSenderId": auth.currentUser?.uid,
        "seen": [auth.currentUser?.uid],
        "lastMsgTime": DateTime.now().toIso8601String(),
        if (isNewMsg) "isGroup": convoId == null,
        if (convoId != null && isNewMsg) "chatName": recipientName,
        if (convoId != null && isNewMsg) "img": recipientImg,
        if (isNewMsg)
          "users": users
              ?.map((e) => {
                    "name": e.name,
                    "img": e.img,
                    "uid": e.uid,
                  })
              .toList(),
        if (isNewMsg)
          "participants": convoId != null
              ? convoId.split("_").toList()
              : FieldValue.arrayUnion([auth.currentUser?.uid])
      }, SetOptions(merge: true));

      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessgaes(String roomId) {
    return fireStore
        .collection('chats')
        .doc(roomId)
        .collection("messages")
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToMsgs() {
    return fireStore.collection('chats').snapshots();
  }

  Future<({List<UserModel>? users, String? error})> getAllUsers() async {
    try {
      final usersData = await fireStore
          .collection("users")
          .withConverter(
              fromFirestore: (snapshot, _) =>
                  UserModel.fromJson(snapshot.data()!),
              toFirestore: (user, _) => user.toJson())
          .where("uid", isNotEqualTo: auth.currentUser?.uid)
          .get();

      return (users: usersData.docs.map((e) => e.data()).toList(), error: null);
    } catch (e) {
      return (users: null, error: e.toString());
    }
  }

  Future<void> updateSeen({String? msgId, String? chatId}) async {
    //adding the current user's id to the message seen
    await fireStore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(msgId)
        .set({
      "seen": FieldValue.arrayUnion([auth.currentUser?.uid])
    }, SetOptions(merge: true));

    final lastMsgDoc = await fireStore.collection("chats").doc(chatId).get();

    //if this message was the last sent message then add the user's add as well.

    if (lastMsgDoc.data()?["lastMsgId"] == msgId &&
        ((lastMsgDoc.data()?["seen"] as List?) ?? []).length < 2) {
      await fireStore.collection('chats').doc(chatId).set({
        "seen": FieldValue.arrayUnion([auth.currentUser?.uid]),
      }, SetOptions(merge: true));
    }
  }
}

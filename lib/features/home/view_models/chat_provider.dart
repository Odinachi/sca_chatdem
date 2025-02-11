import 'dart:io';

import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/features/home/models/message_model.dart';
import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseService firebaseService;

  ChatProvider({required this.firebaseService});

  UserModel? userModel;

  File? chatImg;

  bool isLoading = false;

  List<ChatModel> rooms = [];
  List<ChatModel> dms = [];
  List<UserModel> users = [];
  List<ChatModel> searchedRooms = [];

  void setUserModel(UserModel? model) async {
    userModel = model;
    userModel ??= await firebaseService.getUser();
  }

  void setChatImg(File img) {
    chatImg = img;
    notifyListeners();
  }

  Future<({ChatModel? model, String? error})> createChat(
      ChatModel model) async {
    isLoading = true;
    notifyListeners();
    final createChat = await firebaseService.createChatModel(model);
    if (createChat.model != null) {
      isLoading = false;
      notifyListeners();
      return (model: createChat.model, error: null);
    } else {
      isLoading = false;
      notifyListeners();
      return (model: null, error: createChat.error);
    }
  }

  void fetchRooms() async {
    isLoading = true;
    notifyListeners();
    final chatRooms = await firebaseService.getChatRooms();
    if (chatRooms != null) {
      rooms = List.from(chatRooms);
    }
    isLoading = false;
    notifyListeners();
  }

  void fetchDms() async {
    isLoading = true;
    notifyListeners();
    final chatRooms = await firebaseService.getDms();
    if (chatRooms != null) {
      dms = List.from(chatRooms);
    }
    isLoading = false;
    notifyListeners();
  }

  void fetchUsers() async {
    notifyListeners();
    final allUsers = await firebaseService.getAllUsers();
    if (allUsers.users != null) {
      users = allUsers.users ?? [];
    }
    notifyListeners();
  }

  Future<dynamic> sendMsg({
    String? roomId,
    required String msg,
    String? convoId,
    String? recipientName,
    String? recipientImg,
    required bool isNewMsg,
    String? otherUserId,
  }) async {
    return await firebaseService.sendMessage(
        roomId: roomId,
        convoId: convoId,
        users: [
          userModel!,
          UserModel(
            name: recipientName,
            img: recipientImg,
            uid: otherUserId,
          )
        ],
        isNewMsg: isNewMsg,
        recipientName: recipientName,
        recipientImg: recipientImg,
        msgModel: MessageModel(
            id: userModel?.uid,
            name: userModel?.name,
            time: DateTime.now(),
            image: userModel?.img,
            msg: msg));
  }

  void search(String text) {
    final newRooms = List<ChatModel>.from(rooms);
    newRooms.retainWhere((e) {
      if ((e.chatName ?? "").toLowerCase().contains(text.toLowerCase()) ||
          (e.lastMsg ?? "").toLowerCase().contains(text.toLowerCase())) {
        return true;
      }
      return false;
    });

    searchedRooms = newRooms;
    notifyListeners();
  }

  void clearSearch() {
    searchedRooms.clear();
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMsg(String roomId) =>
      firebaseService.getMessgaes(roomId);
}

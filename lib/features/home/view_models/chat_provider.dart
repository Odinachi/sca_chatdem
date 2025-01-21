import 'dart:io';

import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/features/home/models/message_model.dart';
import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/services/firebase_services.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseService firebaseService;

  ChatProvider({required this.firebaseService});

  UserModel? userModel;

  File? chatImg;

  bool isLoading = false;

  List<ChatModel> rooms = [];

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

  void sendMsg({required String roomId, required String msg}) async {
    await firebaseService.sendMessage(
        roomId: roomId,
        msgModel: MessageModel(
            id: userModel?.uid,
            name: userModel?.name,
            time: DateTime.now(),
            msg: msg));
  }
}

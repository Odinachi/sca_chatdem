import 'package:chatdem/features/home/models/user_model.dart';

class ChatModel {
  final String? chatName;
  final String? id;
  final String? img;
  final String? lastMsg;
  final DateTime? time;
  final DateTime? lastMsgTime;
  final bool? isGroup;
  final List<String>? participants;
  final List<UserModel>? users;

  ChatModel(
      {this.chatName,
      this.id,
      this.img,
      this.time,
      this.lastMsg,
      this.lastMsgTime,
      this.isGroup,
      this.participants,
      this.users});

  ChatModel copyWith({
    String? chatName,
    String? id,
    String? img,
    String? lastMsg,
    DateTime? lastMsgTime,
    DateTime? time,
    bool? isGroup,
    List<String>? participants,
  }) =>
      ChatModel(
        participants: participants ?? this.participants,
        isGroup: isGroup ?? this.isGroup,
        chatName: chatName ?? this.chatName,
        id: id ?? this.id,
        img: img ?? this.img,
        time: time ?? this.time,
        lastMsg: lastMsg ?? this.lastMsg,
        lastMsgTime: lastMsgTime ?? this.lastMsgTime,
        users: users,
      );

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
      chatName: json["chatName"],
      isGroup: json["isGroup"],
      id: json["id"],
      img: json["img"],
      lastMsg: json["lastMsg"],
      time: json["time"] == null ? null : DateTime.parse(json["time"]),
      lastMsgTime: json["lastMsgTime"] == null
          ? null
          : DateTime.parse(
              json["lastMsgTime"],
            ),
      participants: json['participants'] == null
          ? null
          : (json['participants'] as List?)?.map((e) => e.toString()).toList(),
      users: json["users"] == null
          ? null
          : (json['users'] as List).map((e) => UserModel.fromJson(e)).toList());

  Map<String, dynamic> toJson() => {
        'participants': participants,
        "chatName": chatName,
        "isGroup": isGroup,
        "id": id,
        "img": img,
        "lastMsg": lastMsg,
        "time": time?.toIso8601String(),
        "lastMsgTime": lastMsgTime?.toIso8601String(),
      };
}

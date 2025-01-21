class ChatModel {
  final String? chatName;
  final String? id;
  final String? img;
  final String? lastMsg;
  final DateTime? time;
  final DateTime? lastMsgTime;

  ChatModel(
      {this.chatName,
      this.id,
      this.img,
      this.time,
      this.lastMsg,
      this.lastMsgTime});

  ChatModel copyWith({
    String? chatName,
    String? id,
    String? img,
    String? lastMsg,
    DateTime? lastMsgTime,
    DateTime? time,
  }) =>
      ChatModel(
        chatName: chatName ?? this.chatName,
        id: id ?? this.id,
        img: img ?? this.img,
        time: time ?? this.time,
        lastMsg: lastMsg ?? this.lastMsg,
        lastMsgTime: lastMsgTime ?? this.lastMsgTime,
      );

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        chatName: json["chatName"],
        id: json["id"],
        img: json["img"],
        lastMsg: json["lastMsg"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        lastMsgTime: json["lastMsgTime"] == null
            ? null
            : DateTime.parse(json["lastMsgTime"]),
      );

  Map<String, dynamic> toJson() => {
        "chatName": chatName,
        "id": id,
        "img": img,
        "lastMsg": lastMsg,
        "time": time?.toIso8601String(),
        "lastMsgTime": lastMsgTime?.toIso8601String(),
      };
}

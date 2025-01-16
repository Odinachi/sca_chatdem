class ChatModel {
  final String? chatName;
  final String? id;
  final String? img;
  final DateTime? time;

  ChatModel({
    this.chatName,
    this.id,
    this.img,
    this.time,
  });

  ChatModel copyWith({
    String? chatName,
    String? id,
    String? img,
    DateTime? time,
  }) =>
      ChatModel(
        chatName: chatName ?? this.chatName,
        id: id ?? this.id,
        img: img ?? this.img,
        time: time ?? this.time,
      );

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        chatName: json["chatName"],
        id: json["id"],
        img: json["img"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
      );

  Map<String, dynamic> toJson() => {
        "chatName": chatName,
        "id": id,
        "img": img,
        "time": time?.toIso8601String(),
      };
}

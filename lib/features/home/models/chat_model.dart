class ChatModel {
  final String? chatName;
  final String? id;
  final String? img;

  ChatModel({
    this.chatName,
    this.id,
    this.img,
  });

  ChatModel copyWith({
    String? chatName,
    String? id,
    String? img,
  }) =>
      ChatModel(
        chatName: chatName ?? this.chatName,
        id: id ?? this.id,
        img: img ?? this.img,
      );

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        chatName: json["chatName"],
        id: json["id"],
        img: json["img"],
      );

  Map<String, dynamic> toJson() => {
        "chatName": chatName,
        "id": id,
        "img": img,
      };
}

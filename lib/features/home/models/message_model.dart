class MessageModel {
  final String? name;
  final String? id;
  final String? msg;
  final String? image;
  final DateTime? time;

  MessageModel({
    this.name,
    this.id,
    this.msg,
    this.image,
    this.time,
  });

  MessageModel copyWith({
    String? name,
    String? id,
    String? msg,
    String? image,
    DateTime? time,
  }) =>
      MessageModel(
        name: name ?? this.name,
        id: id ?? this.id,
        msg: msg ?? this.msg,
        image: image ?? this.image,
        time: time ?? this.time,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        name: json["name"],
        id: json["id"],
        msg: json["msg"],
        image: json["image"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "msg": msg,
        "image": image,
        "time": time?.toIso8601String(),
      };
}

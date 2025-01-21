class MessageModel {
  final String? name;
  final String? id;
  final String? msg;
  final DateTime? time;

  MessageModel({
    this.name,
    this.id,
    this.msg,
    this.time,
  });

  MessageModel copyWith({
    String? name,
    String? id,
    String? msg,
    DateTime? time,
  }) =>
      MessageModel(
        name: name ?? this.name,
        id: id ?? this.id,
        msg: msg ?? this.msg,
        time: time ?? this.time,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        name: json["name"],
        id: json["id"],
        msg: json["msg"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "msg": msg,
        "time": time?.toIso8601String(),
      };
}

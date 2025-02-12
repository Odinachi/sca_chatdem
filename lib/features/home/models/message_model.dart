class MessageModel {
  final String? name;
  final String? msgId;
  final String? id;
  final String? msg;
  final String? image;
  final DateTime? time;
  final List<String>? seen;

  MessageModel({
    this.name,
    this.id,
    this.msg,
    this.image,
    this.time,
    this.seen,
    this.msgId,
  });

  MessageModel copyWith({
    String? name,
    String? id,
    String? msg,
    String? image,
    String? msgId,
    DateTime? time,
    List<String>? seen,
  }) =>
      MessageModel(
        name: name ?? this.name,
        id: id ?? this.id,
        msg: msg ?? this.msg,
        image: image ?? this.image,
        time: time ?? this.time,
        seen: seen ?? this.seen,
        msgId: msgId ?? this.msgId,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        seen: json['seen'] == null
            ? null
            : (json['seen'] as List?)?.map((e) => e.toString()).toList(),
        name: json["name"],
        id: json["id"],
        msg: json["msg"],
        image: json["image"],
        time: json["time"] == null
            ? null
            : DateTime.parse(
                json["time"],
              ),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "msg": msg,
        "image": image,
        "seen": seen,
        "time": time?.toIso8601String(),
      };
}

class UserModel {
  final String? name;
  final String? uid;
  final String? img;

  UserModel({
    this.name,
    this.uid,
    this.img,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json["name"],
        uid: json["uid"],
        img: json["img"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "img": img,
      };
}

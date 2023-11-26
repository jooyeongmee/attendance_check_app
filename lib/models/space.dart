import 'member.dart';

class Space {
  final String name;
  final List<Member> users;

  const Space({required this.name, required this.users});

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      name: json["name"],
      users: json["users"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "users": users,
    };
  }
}

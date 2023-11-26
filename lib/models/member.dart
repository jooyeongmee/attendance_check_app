enum UserRole { admin, user }

class Member {
  final String uid;
  final String nickname;
  UserRole role;
  bool isChecked;

  Member({
    required this.uid,
    required this.nickname,
    this.role = UserRole.user,
    this.isChecked = false,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      uid: json["uid"],
      nickname: json["nickname"],
      role: _parseUserRole(json["role"]),
      isChecked: json["isChecked"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "nickname": nickname,
      "role": role.toString(),
      "isChecked": isChecked,
    };
  }

  static UserRole _parseUserRole(String role) {
    switch (role) {
      case 'UserRole.admin':
        return UserRole.admin;
      case 'UserRole.user':
        return UserRole.user;
      default:
        throw 'error: $role does not exist';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Member && other.uid == uid;
  }

  @override
  String toString() {
    return "{uid: $uid, nickname: $nickname, role: $role, isChecked: $isChecked,}";
  }
}

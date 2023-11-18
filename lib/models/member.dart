enum UserRole { admin, user }

class Member {
  final String uid;
  final String nickname;
  final UserRole role;

  const Member({required this.uid, required this.nickname, required this.role});
}

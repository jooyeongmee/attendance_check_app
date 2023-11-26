import 'package:attendance_check_app/models/member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final authCollection = FirebaseFirestore.instance.collection('auth');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  String get nickname {
    return _getNicknameFromEmail(currentUser?.email);
  }

  Future<void> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? account = await googleSignIn.signIn();
    print("==============");
    print(account);
    if (account != null) {
      if (_isSparcsMember(account.email)) {
        GoogleSignInAuthentication authentication =
            await account.authentication;
        OAuthCredential googleCredential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );

        UserCredential credential =
            await _firebaseAuth.signInWithCredential(googleCredential);

        final user = credential.user;
        if (user != null) {
          create(
              Member(uid: user.uid, nickname: nickname, role: UserRole.user));
        }
        notifyListeners();
      } else {
        await GoogleSignIn().signOut();
        throw '스팍스 계정으로 로그인 해주세요!';
      }
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    notifyListeners();
  }

  _getNicknameFromEmail(String? email) {
    return email?.split("@")[0];
  }

  _isSparcsMember(String email) {
    return email.split("@")[1] == "sparcs.org";
  }

  void create(Member member) async {
    await authCollection.doc(member.uid).set(member.toJson());
    notifyListeners();
  }

  Future<List<Member>> read() async {
    QuerySnapshot querySnapshot = await authCollection.get();
    return querySnapshot.docs
        .map((authDocument) =>
            Member.fromJson(authDocument.data() as Map<String, dynamic>))
        .toList();
  }
}

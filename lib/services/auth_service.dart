import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
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
    print(account);
    //TODO: account에서 가져온 정보 중 sparcs 계정 필터링 해서 로그인 시키기
    if (account != null && _isSparcsMember(account.email)) {
      GoogleSignInAuthentication authentication = await account.authentication;
      OAuthCredential googleCredential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      UserCredential credential =
          await _firebaseAuth.signInWithCredential(googleCredential);

      final user = credential.user;
      print(user);
      if (user != null) {
        //  User(
        //     uid: user?.uid,
        //     nickname: _getNicknameFromEmail(user?.email),
        //     role: UserRole.admin)
      }

      notifyListeners();
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  _getNicknameFromEmail(String? email) {
    return email?.split("@")[0];
  }

  _isSparcsMember(String email) {
    return email.split("@")[1] == "sparcs.org";
  }
}
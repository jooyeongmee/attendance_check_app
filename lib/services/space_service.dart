import 'package:attendance_check_app/models/space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../models/member.dart';

class SpaceService extends ChangeNotifier {
  final spaceCollection = FirebaseFirestore.instance.collection('space');

  Future<Member> getCurrentMember(String spaceName, User? user) async {
    List<Member> memberList = await fetchUserList(spaceName);
    return memberList.firstWhere((member) => member.uid == user?.uid);
  }

  Future<List<Space>> read() async {
    QuerySnapshot querySnapshot = await spaceCollection.get();
    return querySnapshot.docs
        .map((spaceDocument) =>
            Space.fromJson(spaceDocument.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Member>> fetchUserList(String spaceName) async {
    QuerySnapshot querySnapshot =
        await spaceCollection.doc(spaceName).collection('users').get();
    return querySnapshot.docs
        .map((userDocument) =>
            Member.fromJson(userDocument.data() as Map<String, dynamic>))
        .toList();
  }

  void create(String name, List<Member> userList) async {
    await spaceCollection.doc(name).set(Space(name: name, users: []).toJson());

    CollectionReference usersCollection =
        spaceCollection.doc(name).collection('users');

    for (Member user in userList) {
      await usersCollection.add(user.toJson());
    }
    notifyListeners();
  }

  Future<void> updateAttendance(String spaceName, Barcode barcode) async {
    try {
      QuerySnapshot querySnapshot =
          await spaceCollection.doc(spaceName).collection('users').get();
      QueryDocumentSnapshot<Object?> userDocument = querySnapshot.docs
          .firstWhere((element) =>
              Member.fromJson(element.data() as Map<String, dynamic>).uid ==
              barcode.code);
      if (userDocument.exists) {
        Member member =
            Member.fromJson(userDocument.data() as Map<String, dynamic>);

        member.isChecked = true;

        await userDocument.reference.update(member.toJson());
      }

      List<Member> memberList = await fetchUserList(spaceName);
      memberList.firstWhere((member) => member.uid == barcode.code).isChecked =
          true;
      notifyListeners();
    } catch (e) {
      throw 'qr 코드가 잘못되었습니다.';
    }
  }

  void update(String spaceName, List<Member> userList) async {
    CollectionReference usersCollection =
        spaceCollection.doc(spaceName).collection('users');

    QuerySnapshot existingUsers = await usersCollection.get();
    for (QueryDocumentSnapshot doc in existingUsers.docs) {
      await doc.reference.delete();
    }

    for (Member user in userList) {
      await usersCollection.add(user.toJson());
    }
    notifyListeners();
  }

  void delete(String spaceName) async {
    await spaceCollection.doc(spaceName).delete();
    notifyListeners();
  }
}

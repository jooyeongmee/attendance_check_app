import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/member.dart';

class SpaceService extends ChangeNotifier {
  final spaceCollection = FirebaseFirestore.instance.collection('space');

  Stream<QuerySnapshot> read() {
    return spaceCollection.snapshots();
  }

  void create(String name, Member admin, List<Member> userList) async {
    List<Map<String, String>> userDataList = [
      {
        'nickname': admin.nickname,
        'role': UserRole.admin.toString(),
      },
      ...userList.map((user) {
        return {
          'nickname': user.nickname,
          'role': user.role.toString(),
        };
      }).toList()
    ];

    await spaceCollection.add({
      'name': name,
      'users': userDataList,
    });

    notifyListeners();
  }

  void update(String docId, bool isDone) async {
    await spaceCollection.doc(docId).update({});
    notifyListeners();
  }

  void delete(String docId) async {
    await spaceCollection.doc(docId).delete();
    notifyListeners();
  }
}

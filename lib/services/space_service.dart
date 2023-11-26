import 'package:attendance_check_app/models/space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import '../models/member.dart';

class SpaceService extends ChangeNotifier {
  List<Space> spaceList = [
    Space(
      name: "방 1",
      users: [
        Member(uid: "1", nickname: "ava", role: UserRole.admin),
        Member(uid: "2", nickname: "user", role: UserRole.user)
      ],
    )
  ];

  // read() {
  //   return spaceList;
  // }

  // void create(String name, Member admin, List<Member> userList) {
  //   spaceList.add(Space(id: "2", name: name, users: [admin, ...userList]));
  // }

  // void attendanceCheck(String spaceId, bool isChecked, String userId) {
  //   spaceList
  //       .firstWhere((space) => space.id == spaceId)
  //       .users
  //       .firstWhere((user) => user.uid == userId)
  //       .isChecked = true;
  // }

  final spaceCollection = FirebaseFirestore.instance.collection('space');

  Stream<QuerySnapshot> read() {
    return spaceCollection
        .withConverter<Space>(
            fromFirestore: (snapshot, _) => Space.fromJson(snapshot.data()!),
            toFirestore: (space, _) => space.toJson())
        .snapshots();
  }

  Future<List<Member>> fetchUserList(String spaceName) async {
    QuerySnapshot querySnapshot =
        await spaceCollection.doc(spaceName).collection('users').get();
    print("111");
    print(querySnapshot.docs);
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

  void update(String spaceId, bool isChecked, String userId) async {
    // DocumentReference userDocument =
    //     spaceCollection.doc(spaceId).get('users').doc(userId);
    // await userDocument.update({'isChecked': isChecked});
    // notifyListeners();
  }

  void delete(String docId) async {
    await spaceCollection.doc(docId).delete();
    notifyListeners();
  }
}

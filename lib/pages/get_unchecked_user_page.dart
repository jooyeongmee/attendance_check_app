import 'package:flutter/material.dart';

import '../models/member.dart';

class GetUncheckedUserPage extends StatelessWidget {
  const GetUncheckedUserPage({super.key, required this.userList});

  final List<Member> userList;

  @override
  Widget build(BuildContext context) {
    final uncheckedUserList =
        userList.where((user) => user.isChecked == false).toList();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: uncheckedUserList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.chevron_right),
                title: Text(uncheckedUserList[index].nickname),
              );
            },
          ),
        ),
      ),
    );
  }
}

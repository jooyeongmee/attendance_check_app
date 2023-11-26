import 'package:attendance_check_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';

class AddUserToSpacePage extends StatefulWidget {
  const AddUserToSpacePage({super.key, required this.userListNotifier});

  final ValueNotifier<List<Member>> userListNotifier;

  @override
  State<AddUserToSpacePage> createState() => _AddUserToSpacePageState();
}

class _AddUserToSpacePageState extends State<AddUserToSpacePage> {
  bool selectAll = false;
  late final ValueNotifier<List<Member>> userListNotifier;

  @override
  void initState() {
    userListNotifier = widget.userListNotifier;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      body: FutureBuilder<List<Member>>(
          future: authService.read(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('에러 있음');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("로딩 중");
            }
            final authList = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ValueListenableBuilder(
                  valueListenable: userListNotifier,
                  builder: (context, userList, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: selectAll,
                              onChanged: (checked) {
                                setState(() {
                                  selectAll = !selectAll;
                                  if (selectAll) {
                                    for (Member member in authList) {
                                      if (!userList.contains(member)) {
                                        userList.add(member);
                                      }
                                    }
                                  } else {
                                    userList.clear();
                                  }
                                });
                              },
                            ),
                            const Text("전체 선택"),
                          ],
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: authList.length,
                          itemBuilder: (context, index) {
                            bool isAdded = userList.contains(authList[index]);
                            Member member = isAdded
                                ? userList.firstWhere(
                                    (user) => user == authList[index])
                                : authList[index];
                            bool isLogInnedUser =
                                member.uid == authService.currentUser?.uid;

                            final ValueNotifier<bool> checkedNotifier =
                                ValueNotifier<bool>(isLogInnedUser
                                    ? true
                                    : selectAll || isAdded);
                            final ValueNotifier<bool> isAdminNotifier =
                                ValueNotifier<bool>(isLogInnedUser
                                    ? true
                                    : member.role == UserRole.admin);

                            if (isLogInnedUser && !isAdded) {
                              member.role = UserRole.admin;
                              member.isChecked = true;
                              userList.add(member);
                            }

                            return ListTile(
                              leading: ValueListenableBuilder(
                                valueListenable: checkedNotifier,
                                builder: (context, value, child) {
                                  return Checkbox(
                                    value: value,
                                    onChanged: (checked) {
                                      if (userList.contains(member)) {
                                        userList.remove(member);
                                      } else {
                                        userList.add(member);
                                      }
                                      checkedNotifier.value = checked!;
                                    },
                                  );
                                },
                              ),
                              title: Text(member.nickname),
                              trailing: ValueListenableBuilder(
                                valueListenable: isAdminNotifier,
                                builder: (context, value, child) {
                                  return InkWell(
                                    child: value
                                        ? const Text("관리자")
                                        : const Text("유저"),
                                    onTap: () {
                                      if (!value) {
                                        userList
                                            .firstWhere(
                                                (user) => user == member)
                                            .role = UserRole.admin;
                                      } else {
                                        userList
                                            .firstWhere(
                                                (user) => user == member)
                                            .role = UserRole.user;
                                      }
                                      if (member.role == UserRole.admin) {
                                        userList
                                            .firstWhere(
                                                (user) => user == member)
                                            .isChecked = true;
                                      }
                                      isAdminNotifier.value =
                                          !isAdminNotifier.value;
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, [userList]);
                            },
                            child: const Text("완료"),
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  }),
            );
          }),
    );
  }
}

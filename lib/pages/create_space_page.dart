import 'package:attendance_check_app/models/member.dart';
import 'package:attendance_check_app/services/space_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_user_to_space_page.dart';

class CreateSpacePage extends StatefulWidget {
  const CreateSpacePage({super.key, this.spaceName, this.userList});

  final String? spaceName;
  final List<Member>? userList;

  @override
  State<CreateSpacePage> createState() => _CreateSpacePageState();
}

class _CreateSpacePageState extends State<CreateSpacePage> {
  final spaceNameController = TextEditingController();
  late final ValueNotifier<List<Member>> userListNotifier;

  @override
  void initState() {
    super.initState();
    userListNotifier = ValueNotifier<List<Member>>(
        widget.userList == null ? [] : widget.userList!);
  }

  @override
  Widget build(BuildContext context) {
    final spaceService = context.read<SpaceService>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "방 이름: ",
                      style: TextStyle(
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                          height: 4.5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        enabled: widget.spaceName == null,
                        controller: spaceNameController,
                        autofocus: true,
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(
                          hintText: widget.spaceName,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: userListNotifier,
                      builder: (context, value, child) {
                        return Text("현재 인원 ${value.length}명");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddUserToSpacePage(
                                  userListNotifier: userListNotifier)));
                      List<Member> userList = result[0];

                      setState(() {
                        userListNotifier.value = userList;
                      });
                    },
                    child: const Text("인원 관리"),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final spaceName = spaceNameController.text.trim();
                      final isSpaceNameDuplicate =
                          await spaceService.isSpaceNameDuplicate(spaceName);
                      if (!context.mounted) return;
                      if (widget.spaceName == null && spaceName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('방 이름을 적어주세요.')),
                        );
                      } else if (isSpaceNameDuplicate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이미 생성된 방입니다.')),
                        );
                      } else {
                        Navigator.pop(context, [
                          spaceNameController.text.trim(),
                          userListNotifier.value
                        ]);
                      }
                    },
                    child: const Text("완료"),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

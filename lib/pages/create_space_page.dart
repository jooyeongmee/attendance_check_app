import 'package:attendance_check_app/models/member.dart';
import 'package:flutter/material.dart';

class CreateSpacePage extends StatefulWidget {
  const CreateSpacePage({super.key});

  @override
  State<CreateSpacePage> createState() => _CreateSpacePageState();
}

class _CreateSpacePageState extends State<CreateSpacePage> {
  @override
  Widget build(BuildContext context) {
    final spaceNameController = TextEditingController();
    final userNameController = TextEditingController();
    List<Member> userList = [];

    final ValueNotifier<bool> _admin = ValueNotifier<bool>(false);
    final ValueNotifier<int> _userCount = ValueNotifier<int>(userList.length);

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
                        controller: spaceNameController,
                        autofocus: true,
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _admin,
                      builder: (context, value, child) {
                        return Transform.scale(
                          alignment: AlignmentDirectional.centerEnd,
                          scale: 0.7,
                          child: Checkbox(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: _admin.value,
                            onChanged: (value) {
                              _admin.value = value!;
                            },
                          ),
                        );
                      },
                    ),
                    const Text(
                      "관리자",
                    ),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: _userCount,
                      builder: (context, value, child) {
                        return Text("현재 인원 ${_userCount.value}명");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      userList.add(Member(
                          uid: "",
                          nickname: userNameController.text,
                          role: _admin.value ? UserRole.admin : UserRole.user));
                      _userCount.value++;
                      _admin.value = false;
                      userNameController.clear();
                    },
                    child: const Text("추가"),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context, [spaceNameController.text, userList]);
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

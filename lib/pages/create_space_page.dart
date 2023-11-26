import 'package:attendance_check_app/models/member.dart';
import 'package:flutter/material.dart';

import 'add_user_to_space_page.dart';

class CreateSpacePage extends StatefulWidget {
  const CreateSpacePage({super.key});

  @override
  State<CreateSpacePage> createState() => _CreateSpacePageState();
}

class _CreateSpacePageState extends State<CreateSpacePage> {
  @override
  Widget build(BuildContext context) {
    final spaceNameController = TextEditingController();
    
    final ValueNotifier<List<Member>> userListNotifier =
        ValueNotifier<List<Member>>([]);

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
                              builder: (context) =>
                                  const AddUserToSpacePage()));
                      List<Member> userList = result[0];
                      userListNotifier.value = userList;
                    },
                    child: const Text("인원 추가"),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context, [spaceNameController.text, userListNotifier.value]);
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

import 'package:attendance_check_app/pages/create_space_page.dart';
import 'package:attendance_check_app/services/space_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/member.dart';
import 'models/space.dart';
import 'pages/admin_attendance_check_page.dart';
import 'pages/login_page.dart';
import 'pages/user_attendance_check_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => SpaceService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthService>().currentUser;
    return MaterialApp(
      title: 'Attendance Check App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: currentUser == null
          ? const LoginPage()
          : MyHomePage(user: currentUser),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.user});
  final User user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final spaceService = context.watch<SpaceService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        authService.signOut();
                      },
                      child: const Text("로그아웃"),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      authService.nickname,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: FutureBuilder<List<Space>>(
                    future: spaceService.read(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('에러 있음');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("로딩 중");
                      }
                      final List<Space> spaceList = snapshot.data ?? [];
                      return GridView.builder(
                          shrinkWrap: true,
                          itemCount: spaceList.length + 1,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Column(
                                children: [
                                  const SizedBox(height: 5),
                                  if (index < spaceList.length)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final userList = await spaceService
                                                .fetchUserList(
                                                    spaceList[index].name);
                                            if (!context.mounted) return;
                                            final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateSpacePage(
                                                          spaceName:
                                                              spaceList[index]
                                                                  .name,
                                                          userList: userList),
                                                ));
                                            List<Member> updatedUserList =
                                                result[1];
                                            spaceService.update(
                                                spaceList[index].name,
                                                updatedUserList);
                                          },
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            spaceService
                                                .delete(spaceList[index].name);
                                          },
                                          child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                    ),
                                  const SizedBox(height: 45),
                                  GestureDetector(
                                    onTap: () async {
                                      if (index >= spaceList.length) {
                                        final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CreateSpacePage(),
                                            ));
                                        String spaceName = result[0];
                                        List<Member> userList = result[1];
                                        spaceService.create(
                                          spaceName,
                                          userList,
                                        );
                                      } else {
                                        String spaceName =
                                            spaceList[index].name;
                                        Member currentMember =
                                            await spaceService.getCurrentMember(
                                                spaceName, widget.user);
                                        if (!context.mounted) return;
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  currentMember.role ==
                                                          UserRole.admin
                                                      ? AdminAttendanceCheckPage(
                                                          spaceName: spaceName,
                                                        )
                                                      : UserAttendanceCheckPage(
                                                          currentMember:
                                                              currentMember,
                                                          spaceName: spaceName,
                                                        ),
                                            ));
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Center(
                                        child: index < spaceList.length
                                            ? Text(spaceList[index].name)
                                            : const Icon(
                                                Icons.add,
                                                size: 80,
                                                color: Colors.black54,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

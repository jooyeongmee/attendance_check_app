import 'package:attendance_check_app/pages/create_space_page.dart';
import 'package:attendance_check_app/services/space_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/member.dart';
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
    final authService = context.read<AuthService>();
    final spaceService = context.read<SpaceService>();

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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: spaceService.read(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('에러 있음');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("로딩 중");
                      }
                      final spaceList = snapshot.data?.docs ?? [];
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
                            return GestureDetector(
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
                                      spaceList[index].get('name');
                                  Member currentMember = await spaceService
                                      .getCurrentMember(spaceName, widget.user);
                                  print(currentMember);
                                  if (!context.mounted) return;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            currentMember.role == UserRole.admin
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
                              child: Card(
                                child: Center(
                                  child: index < spaceList.length
                                      ? Text(spaceList[index].get('name') ??
                                          "asdf")
                                      : const Icon(
                                          Icons.add,
                                          size: 80,
                                          color: Colors.black54,
                                        ),
                                ),
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

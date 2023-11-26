import 'package:flutter/material.dart';

class UserAttendanceCheckPage extends StatefulWidget {
  const UserAttendanceCheckPage({super.key, required this.spaceName});

  final String spaceName;

  @override
  State<UserAttendanceCheckPage> createState() =>
      _UserAttendanceCheckPageState();
}

class _UserAttendanceCheckPageState extends State<UserAttendanceCheckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}

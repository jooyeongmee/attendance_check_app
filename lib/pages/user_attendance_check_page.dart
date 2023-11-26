import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/member.dart';

class UserAttendanceCheckPage extends StatefulWidget {
  const UserAttendanceCheckPage(
      {super.key, required this.spaceName, required this.currentMember});

  final String spaceName;
  final Member currentMember;

  @override
  State<UserAttendanceCheckPage> createState() =>
      _UserAttendanceCheckPageState();
}

class _UserAttendanceCheckPageState extends State<UserAttendanceCheckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("nickname: ${widget.currentMember.nickname}"),
              QrImageView(
                data: widget.currentMember.uid,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

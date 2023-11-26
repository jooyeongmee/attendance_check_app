import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManage {
  Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.request();

    if (context.mounted && !status.isGranted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("권한 설정을 확인해주세요."),
              actions: [
                TextButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text('설정하기')),
              ],
            );
          });
      return false;
    }
    return true;
  }
}

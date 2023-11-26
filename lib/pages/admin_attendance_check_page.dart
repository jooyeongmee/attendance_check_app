import 'dart:io';

import 'package:attendance_check_app/models/member.dart';
import 'package:attendance_check_app/models/space.dart';
import 'package:attendance_check_app/services/space_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'get_unchecked_user_page.dart';

class AdminAttendanceCheckPage extends StatefulWidget {
  const AdminAttendanceCheckPage({super.key, required this.spaceName});

  final String spaceName;

  @override
  State<AdminAttendanceCheckPage> createState() => _AttendanceCheckPageState();
}

class _AttendanceCheckPageState extends State<AdminAttendanceCheckPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final spaceService = context.read<SpaceService>();
    List<Member> _userList = [];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<List<Member>>(
                future: spaceService.fetchUserList(widget.spaceName),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('에러 있음');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("로딩 중");
                  }
                  final userList = snapshot.data ?? [];
                  _userList = userList;
                  final checkedUser =
                      userList.where((user) => user.isChecked == true).toList();
                  return Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8)
                          .copyWith(top: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("방: ${widget.spaceName}"),
                          const Spacer(),
                          Text("출석: ${checkedUser.length}/${userList.length}")
                        ],
                      ),
                    ),
                  );
                }),
            Expanded(flex: 5, child: _buildQrView(context)),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: result != null
                        ? Text(
                            'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                        : const Text('Scan a code'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Text('Flash: ${snapshot.data}',
                                  style: const TextStyle(fontSize: 12));
                            },
                          )),
                      TextButton(
                        onPressed: () async {
                          await controller?.flipCamera();
                          setState(() {});
                        },
                        child: FutureBuilder(
                          future: controller?.getCameraInfo(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return Text(
                                  'Camera facing ${describeEnum(snapshot.data!)}',
                                  style: const TextStyle(fontSize: 12));
                            } else {
                              return const Text('loading');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GetUncheckedUserPage(userList: _userList),
                            ),
                          );
                        },
                        child: const Text("미출석 인원")),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

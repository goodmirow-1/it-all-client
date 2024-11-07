import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_assets.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/dashboard/controller/dashboard_controller.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:intl/intl.dart';

class QrPage extends StatelessWidget {
  QrPage({Key? key, required this.qrType}) : super(key: key);

  static const int qrTypeAttendance = 0; // 출석 QR
  static const int qrTypeOuting = 1; // 외출 QR

  final int qrType;

  final DashboardController controller = Get.find<DashboardController>();

  bool get isAttendance => qrType == qrTypeAttendance;

  @override
  Widget build(BuildContext context) {
    if(kDebugMode) print('{"type": ${isAttendance ? controller.attendanceQRStatus.value : controller.outingQRStatus.value}, "userID": ${GlobalData.loginUser.id}, "classID": ${GlobalData.loginUser.classID}, "userName": "${GlobalData.loginUser.name}"}');

    return BaseWidget(
      child: Scaffold(
        appBar: appBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('남은시간 ', style: STextStyle.subTitle3()),
                  Countdown(
                    seconds: 180,
                    build: (BuildContext context, double time) => Text(DateFormat('mm:ss').format(DateTime(0, 0, 0, 0, time ~/ 60, (time % 60).toInt())), style: STextStyle.subTitle3()),
                    onFinished: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 40 * sizeUnit),
              QrImage(
                // type || userID || classID || userName
                data: '{"type": ${isAttendance ? controller.attendanceQRStatus.value : controller.outingQRStatus.value}, "userID": ${GlobalData.loginUser.id}, "classID": ${GlobalData.loginUser.classID}, "userName": "${GlobalData.loginUser.name}"}',
                size: 276 * sizeUnit,
              ),
              SizedBox(height: 58 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: isAttendance ? '출석코드' : '외출코드',
      leading: Center(
        child: GestureDetector(
          onTap: () => Get.back(),
          child: SvgPicture.asset(
            GlobalAssets.svgCancel,
            width: 24 * sizeUnit,
          ),
        ),
      ),
    );
  }
}

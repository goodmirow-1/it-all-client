import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/dashboard/controller/attendance_status_page_controller.dart';
import 'package:intl/intl.dart';

import '../data/model/attendance.dart';

class AttendanceStatusPage extends StatelessWidget {
  AttendanceStatusPage({Key? key, required this.status}) : super(key: key);

  final String status;

  final AttendanceStatusPageController controller = Get.put(AttendanceStatusPageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: status),
        body: GetBuilder<AttendanceStatusPageController>(
            initState: (state) => controller.initState(status),
            builder: (context) {
              return ListView.builder(
                itemCount: controller.attendanceList.length,
                itemBuilder: (context, index) => attendanceItem(controller.attendanceList[index]),
              );
            }),
      ),
    );
  }

  Container attendanceItem(Attendance attendance) {
    return Container(
      padding: EdgeInsets.all(16 * sizeUnit),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: iaColorGrey),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(status == '결석' ? 'yyyy.MM.dd' : 'yyyy.MM.dd HH시 mm분').format(attendance.time),
            style: STextStyle.subTitle4().copyWith(color: iaColorRed),
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            Attendance.typeToText(attendance.type),
            style: STextStyle.subTitle3(),
          ),
        ],
      ),
    );
  }
}

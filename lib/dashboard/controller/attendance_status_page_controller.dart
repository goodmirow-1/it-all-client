import 'package:get/get.dart';
import 'package:itall_app/data/global_data.dart';

import '../../data/model/attendance.dart';

class AttendanceStatusPageController extends GetxController {
  static get to => Get.find<AttendanceStatusPageController>();

  late final String status;
  List<Attendance> attendanceList = [];

  void initState(String status) {
    this.status = status;
    attendanceList = setData(); // status 따라 데이터 세팅
  }

  List<Attendance> setData() {
    switch (status) {
      case '출석':
        return getList([Attendance.typeAttendance, Attendance.typeEarlyAttendance, Attendance.typeUnauthorizedLateness, Attendance.typeLateness]);
      case '지각':
        return getList([Attendance.typeUnauthorizedLateness, Attendance.typeLateness]);
      case '조퇴':
        return getList([Attendance.typeUnauthorizedEarlyLeave, Attendance.typeEarlyLeave]);
      case '외출':
        return getList([Attendance.typeUnauthorizedOuting, Attendance.typeOuting]);
      case '결석':
        return getList([Attendance.typeUnauthorizedAbsent, Attendance.typeAbsent]);
      default:
        return [];
    }
  }

  List<Attendance> getList(List<int> typeList) {
    List<Attendance> list = [];

    for (int i = 0; i < GlobalData.loginUser.attendances.length; i++) {
      final Attendance attendance = GlobalData.loginUser.attendances[i];

      for (int j = 0; j < typeList.length; j++) {
        if (attendance.type == typeList[j]) {
          list.add(attendance);
          break;
        }
      }
    }

    return list;
  }
}

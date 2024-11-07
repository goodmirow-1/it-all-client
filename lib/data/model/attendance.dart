import 'package:itall_app/config/constants.dart';

import '../../config/global_function.dart';

class Attendance {
  static const int typeAttendance = 0; // 등원
  static const int typeEarlyAttendance = 1; // 이른 등원
  static const int typeUnauthorizedLateness = 2; // 무단 지각
  static const int typeLateness = 3; // 사유 지각
  static const int typeReAttendance = 4; // 재등원
  static const int typeUnauthorizedOuting = 5; // 무단 외출
  static const int typeOuting = 6; // 사유 외출
  static const int typeOutingReturn = 7; // 외출 복귀
  static const int typeUnauthorizedEarlyLeave = 8; // 무단 조퇴
  static const int typeEarlyLeave = 9; // 사유 조퇴
  static const int typeUnauthorizedAbsent = 10; // 무단 결석
  static const int typeAbsent = 11; // 사유 결석
  static const int typeLeave = 12; // 하원

  Attendance({
    required this.id,
    required this.userID,
    required this.centerID,
    required this.type,
    this.description,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userID;
  final int centerID;
  final int type;
  final String? description;
  final DateTime time;
  final String createdAt;
  final String updatedAt;

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userID: json['UserID'],
      centerID: json['CenterID'] ?? nullInt,
      type: json['Type'],
      description: json['Description'],
      time: DateTime.parse(json['Time']).add(const Duration(hours: 9)),
      createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
      updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
    );
  }

  // 출석 type -> text
  static String typeToText(int type){
    switch(type) {
      case Attendance.typeAttendance: // 등원
        return '등원';
      case Attendance.typeEarlyAttendance: // 이른 등원
        return '이른 등원';
      case Attendance.typeUnauthorizedLateness: // 무단 지각
        return '무단 지각';
      case Attendance.typeLateness: // 사유 지각
        return '사유 지각';
      case Attendance.typeReAttendance: // 재등원
        return '재등원';
      case Attendance.typeUnauthorizedOuting: // 무단 외출
        return '무단 외출';
      case Attendance.typeOuting: // 사유 외출
        return '사유 외출';
      case Attendance.typeOutingReturn: // 외출 복귀
        return '외출 복귀';
      case Attendance.typeUnauthorizedEarlyLeave: // 무단 조퇴
        return '무단 조퇴';
      case Attendance.typeEarlyLeave: // 사유 조퇴
        return '사유 조퇴';
      case Attendance.typeUnauthorizedAbsent: // 무단 결석
        return '무단 결석';
      case Attendance.typeAbsent: // 사유 결석
        return '사유 결석';
      case Attendance.typeLeave: // 하원
        return '하원';
      default:
        return '';
    }
  }
}

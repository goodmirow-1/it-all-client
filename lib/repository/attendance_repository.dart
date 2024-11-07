import 'dart:convert';

import '../data/model/absence.dart';
import '../data/model/attendance.dart';
import '../data/model/public_space_use.dart';
import '../network/ApiProvider.dart';

class AttendanceRepository {
  static const String defaultURL = '/Attendance';

  // 예외 신청
  static Future<dynamic> registerAbsence({
    required int userID,
    required int withVacation,
    required int type,
    required String periodStart,
    required String periodEnd,
    required String reason,
  }) async {
    var res = await ApiProvider().post(
        '$defaultURL/Register/Absence',
        jsonEncode({
          "userID": userID,
          "withVacation": withVacation, // 0이면 안씀, 1:외출권, 2:반휴권, 3:휴가권
          "type": type, // 0:외출,1:조퇴,2:결석,3:지각
          "periodStart": periodStart,
          "periodEnd": periodEnd,
          "reason": reason,
        }));

    return res;
  }

  // 정기 예외 신청
  static Future<dynamic> registerRegularAbsence({
    required int userID,
    required int type,
    required String periodStart,
    required String periodEnd,
    required String reason,
    required bool monday,
    required bool tuesday,
    required bool wednesday,
    required bool thursday,
    required bool friday,
    required bool saturday,
    required bool sunday,
  }) async {
    var res = await ApiProvider().post(
        '$defaultURL/Register/Regular/Absence',
        jsonEncode({
          "userID": userID,
          "type": type, // 0:외출,1:결석
          "periodStart": periodStart,
          "periodEnd": periodEnd,
          "reason": reason,
          "monday": monday,
          "tuseday": tuesday,
          "wednesday": wednesday,
          "thursday": thursday,
          "friday": friday,
          "saturday": saturday,
          "sunday": sunday,
        }));

    return res;
  }

  // 예외 불러오기
  static Future<List<Absence>> selectAbsenceByUserID({required int userID}) async {
    List<Absence> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/Absence/By/UserID',
        jsonEncode({
          "userID": userID,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        list.insert(0, Absence.fromJson(res[i]));
      }
    }

    return list;
  }

  // 정기 예외 불러오기
  static Future<List<AbsenceRegular>> selectRegularAbsenceByUserID({required int userID}) async {
    List<AbsenceRegular> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/Regular/Absence/By/UserID',
        jsonEncode({
          "userID": userID,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        list.insert(0, AbsenceRegular.fromJson(res[i]));
      }
    }

    return list;
  }

  // 예외 처리
  static Future<dynamic> modifyAcception({required bool isRegular, required int id, required bool acception, required int userID}) async {
    var res = await ApiProvider().post(
        '$defaultURL/Modify/Acception',
        jsonEncode({
          "isRegular": isRegular,
          "id": id,
          "acception": acception,
          "userID": userID,
        }));

    return res;
  }

  // 이번달 공용공간 사용 개수 가져오기
  static Future<int> selectPublicSpaceUseCount({required int userID}) async {
    var res = await ApiProvider().post(
        '$defaultURL/Select/PublicSpaceUse/Count',
        jsonEncode({
          "userID": userID,
        }));

    if (res != null) {
      return res.length;
    } else {
      return 0;
    }
  }

  // 공용공간 사용 이력 가져오기
  static Future<List<PublicSpaceUse>> selectPublicSpaceUseListByUserID({required int userID}) async {
    List<PublicSpaceUse> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/PublicSpaceUseList/By/UserID',
        jsonEncode({
          "userID": userID,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        list.add(PublicSpaceUse.fromJson(res[i]));
      }
    }

    return list;
  }

  // 공용공간 사용 이력 가져오기
  static Future<List<Attendance>> selectByUserID({required int userID}) async {
    List<Attendance> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/By/UserID',
        jsonEncode({
          "userID": userID,
        }));

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        list.add(Attendance.fromJson(res[i]));
      }
    }

    return list.reversed.toList();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:itall_app/home/splash_screen.dart';
import 'package:itall_app/login/login_page.dart';
import 'package:itall_app/login/password_setting_page.dart';
import 'package:itall_app/repository/center_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../data/global_data.dart';
import '../data/model/absence.dart';
import '../data/model/student.dart';
import '../home/main_page.dart';
import '../network/firebaseNotification.dart';
import '../repository/attendance_repository.dart';
import '../repository/student_repository.dart';
import 'constants.dart';
import 'global_assets.dart';
import 'global_widgets/global_widget.dart';

class GlobalFunction {
  // 포커스 해제 함수
  static void unFocus(BuildContext context) {
    FocusManager.instance.primaryFocus!.unfocus();
  }

  //직업명 제한 규칙
  static String? validJobErrorText(String text) {
    if (text.isEmpty) return null;

    int utf8Length = utf8.encode(text).length;
    if (text.length < 2) {
      return "2자 이상 작성해주세요.";
    }
    if (text.length > 12 || utf8Length > 24) {
      return "한글 8자 또는 영문 12자 이하로 작성해 주세요.";
    }

    bool pass = true;

    RegExp regExp = RegExp(r'[가-힣|a-z|A-Z|\s]'); //한글, 영문, 띄어쓰기만 입력 가능

    List charList = text.split('');

    bool spaceFirstCheck = true;
    for (int i = 0; i < charList.length; i++) {
      if (regExp.hasMatch(charList[i])) {
      } else {
        pass = false;
        break;
      }
      if (charList[i] == ' ') {
        if (spaceFirstCheck) {
          //첫번째 공백을 제외한 공백이 있을 경우 알림
          spaceFirstCheck = false;
        } else {
          pass = false;
          break;
        }
      }
    }

    if (pass) {
      return null;
    } else {
      return "한글, 영문, 한개의 공백만 사용해주세요.";
    }
  }

  static String replaceDate(String date) {
    if (date == "") return "";

    DateTime dateTime = DateTime.parse(date);
    dateTime = dateTime.add(const Duration(hours: 9)); //zone 시간 더함(아마존 서버로 접근할 시 -필요)

    String replaceStr = dateTime.toString();
    return replaceStr.replaceAll('T', ' ').replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '');
  }

  static String replaceDateToDateTime(String date) {
    DateTime dateTime = DateTime.parse(date);
    //dateTime = dateTime.add(const Duration(hours: 9)); //zone 시간 더함(아마존 서버로 접근할 시 -필요)

    String months = dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
    String days = dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();

    String hours = dateTime.hour < 10 ? '0${dateTime.hour}' : dateTime.hour.toString();
    String minutes = dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute.toString();
    String seconds = dateTime.second < 10 ? '0${dateTime.second}' : dateTime.second.toString();

    return '${dateTime.year}-$months-$days $hours:$minutes:$seconds';
  }

  // 토스트
  static void showToast({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: iaColorRed,
      textColor: Colors.white,
    );
  }

  // 로딩 다이어로그
  static void loadingDialog() {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: SvgPicture.asset(
            GlobalAssets.svgLogo,
            color: Colors.white,
            width: 40 * sizeUnit,
          ),
        ),
      ),
    );
  }

  // 요일 한글 변환 함수
  static String changeDayOfTheWeekToKorean(String dayOfTheWeek) {
    switch (dayOfTheWeek) {
      case 'Mon':
        return '월요일';
      case 'Tue':
        return '화요일';
      case 'Wed':
        return '수요일';
      case 'Thu':
        return '목요일';
      case 'Fri':
        return '금요일';
      case 'Sat':
        return '토요일';
      case 'Sun':
        return '일요일';
      default:
        return '월요일';
    }
  }

  // 앱 종료 체크 함수
  static Future<bool> isEnd() async {
    final DateTime now = DateTime.now();

    if (GlobalData.currentBackPressTime == null || now.difference(GlobalData.currentBackPressTime!) > const Duration(seconds: 2)) {
      GlobalData.currentBackPressTime = now;
      GlobalFunction.showToast(msg: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.');

      return Future.value(false);
    }
    return Future.value(true);
  }

  // 영어 요일 한국어로
  static String dayOfTheWeekInKorean(String text) {
    switch (text) {
      case 'Monday':
        return '월';
      case 'Tuesday':
        return '화';
      case 'Wednesday':
        return '수';
      case 'Thursday':
        return '목';
      case 'Friday':
        return '금';
      case 'Saturday':
        return '토';
      case 'Sunday':
        return '일';
      default:
        return '월';
    }
  }

  // 파일크기 측정
  static Future<bool> isBigFile(var file) async {
    int fileSize = (await file.readAsBytes()).lengthInBytes;

    //약 2mb
    if (fileSize >= 2097152) return Future.value(true);
    return Future.value(false);
  }

  // 로그인
  static Future<void> globalLogin({required String id, required String password, required Function nullCallback}) async {
    late final String processedID; // 뒤에 p뺀 가공된 id

    if(Get.currentRoute != SplashScreen.route) loadingDialog(); // 로딩 시작

    // 학부모 로그인인지 판단
    if (id[id.length - 1] == parentsLoginString) {
      GlobalData.isParents = true;
      processedID = id.substring(0, id.length - 1);
    } else {
      GlobalData.isParents = false;
      processedID = id;
    }

    // 숫자만 포함되어 있는지 확인
    if (!validNumber(processedID)) {
      if(Get.currentRoute != SplashScreen.route) Get.back(); // 로딩 끝
      nullCallback();
      return;
    }

    // 로그인
    var res = await StudentRepository.login(
      number: int.parse(processedID),
      password: password,
      isParentLogin: GlobalData.isParents,
    );

    if (res != null && res['student'] != null) {
      GlobalData.loginUser = Student.fromJson(res['student']); // 유저 세팅
      GlobalData.loginUser.className = res['eduClass']['Name'] ?? '';
      GlobalData.studyingCount = res['studingCount']; // 공부중인 학생 세팅

      await setCenter(); // 센터 세팅
      if(GlobalData.isParents) GlobalData.exceptionCheckCount = await setExceptionCheckCount(); // 부모인 경우 사유확인 개수 세팅
    } else {
      if(Get.currentRoute != SplashScreen.route) Get.back(); // 로딩 끝
      nullCallback();
      return;
    }

    // 비밀번호 설정이 필요한 경우
    if (password.length == defaultPasswordLength) {
      Get.offAll(() => PasswordSettingPage(id: id));
    } else {
      final prefs = await SharedPreferences.getInstance();

      // 자동 로그인 데이터 세팅
      prefs.setString('id', id);
      prefs.setString('password', password);

      // d-day 세팅
      GlobalData.dDay(prefs.getString('dDay') ?? '');
      GlobalData.dDayText(prefs.getString('dDayText') ?? '');

      // d-day 지난 경우 삭제
      if (GlobalData.dDay.isNotEmpty) {
        final DateTime now = DateTime.now();
        final int dDay = DateTime.parse(GlobalData.dDay.value).difference(DateTime(now.year, now.month, now.day)).inDays;

        if (dDay < 0) {
          prefs.remove('dDay');
          prefs.remove('dDayText');
          GlobalData.dDay('');
          GlobalData.dDayText('');
        }
      }

      if (!kIsWeb) {
        FirebaseNotifications().setFcmToken('');
        FirebaseNotifications().setUpFirebase();
      }

      Get.offAll(() => MainPage());
    }
  }

  // 센터 세팅
  static Future<void> setCenter() async{
    List<Map<String, dynamic>> centerMapList = await CenterRepository.selectList();

    for(int i = 0; i < centerMapList.length; i++) {
      final Map<String, dynamic> map = centerMapList[i];

      if(GlobalData.loginUser.centerID == map['id']) {
        GlobalData.loginUser.centerName = map['name'];
        break;
      }
    }
  }

  // 사유확인 개수 세팅
  static Future<int> setExceptionCheckCount() async{
    final DateTime now = DateTime.now();
    int nullCount = 0;
    final List<Absence> absenceList = await AttendanceRepository.selectAbsenceByUserID(userID: GlobalData.loginUser.id);
    final List<AbsenceRegular> absenceRegularList = await AttendanceRepository.selectRegularAbsenceByUserID(userID: GlobalData.loginUser.id);

    // 개별
    for (int i = 0; i < absenceList.length; i++) {
      final Absence absence = absenceList[i];
      final bool timeOver = absence.periodStart.difference(now).inMinutes <= 0;

      if (!timeOver && absence.acception == null) nullCount++;
    }

    // 정기
    for (int i = 0; i < absenceRegularList.length; i++) {
      final AbsenceRegular absenceRegular = absenceRegularList[i];
      if (absenceRegular.acception == null) nullCount++;
    }

    return nullCount;
  }

  // 로그아웃
  static Future<void> globalLogout() async{
    if (kDebugMode) print('logout!');
    loadingDialog(); // 로딩 시작
    bool? result = await StudentRepository.logout(userID: GlobalData.loginUser.id, token: FirebaseNotifications.getFcmToken);

    if(result == true) {
      GlobalData.resetData(); // 글로벌 데이터 리셋
      resetPreferenceData(); // preference data 리셋

      Get.offAll(() => LoginPage());
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // preference data 리셋
  static Future<void> resetPreferenceData() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('id');
    prefs.remove('password');
    prefs.remove('dDay');
    prefs.remove('dDayText');
  }

  // 숫자만 포함되어 있는지 확인
  static bool validNumber(String id) {
    if (id.isEmpty) return false;

    RegExp regExp = RegExp(r"^[0-9]*$"); // 숫자만 입력 가능
    List charList = id.split('');

    for (int i = 0; i < charList.length; i++) {
      if (!regExp.hasMatch(charList[i])) return false;
    }

    return true;
  }

  // createdAt -> date
  static String createdAtToDate({required String createdAt, String? pattern}){
    return DateFormat(pattern ?? 'yyyy.MM.dd').format(DateTime(int.parse(createdAt.substring(0, 4)), int.parse(createdAt.substring(4, 6)), int.parse(createdAt.substring(6, 8)), int.parse(createdAt.substring(8, 10)), int.parse(createdAt.substring(10, 12))));
  }
}

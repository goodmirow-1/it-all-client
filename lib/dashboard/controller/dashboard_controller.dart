import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/model/attendance.dart';
import '../../data/model/attendance_history_data.dart';
import '../../data/model/student.dart';
import '../../repository/attendance_repository.dart';
import '../../repository/student_repository.dart';

class DashboardController extends GetxController {
  static get to => Get.find<DashboardController>();

  static const int qrStatusAttendance = 1; // 등원
  static const int qrStatusLeave = 2; // 하원
  static const int qrStatusOuting = 3; // 외출
  static const int qrStatusReturn = 4; // 복귀

  final ScrollController dashboardScrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final DateTime now = DateTime.now();
  late DateTime firstChartDate; // 첫번째 데이터의 date
  late DateTime lastChartDate; // 마지막 데이터의 date
  late int differDays; // 마지막 데이터와 첫번째 데이터의 일수 차이

  RxInt attendanceQRStatus = qrStatusAttendance.obs; // 등원 qr
  RxInt outingQRStatus = qrStatusOuting.obs; // 외출 qr

  RxInt selectedIndex = 1.obs;
  List<AttendanceHistoryData> attendanceHistoryList = [];
  bool allowScrollControl = false; // 스크롤 컨트롤 허용 여부

  int attendanceCount = 0; // 출석
  int latenessCount = 0; // 지각
  int earlyLeaveCount = 0; // 조퇴
  int outingCount = 0; // 외출
  int absentCount = 0; // 결석

  @override
  void onClose() {
    super.onClose();

    dashboardScrollController.dispose();
  }

  void initState() {
    blockScroll(); // 스크롤 0.5초 이후부터 가능하도록
    if (attendanceHistoryList.isNotEmpty) return; // 이미 세팅했으면 리턴
    if (GlobalData.loginUser.attendances.isEmpty) return; // 출석 데이터 없으면 리턴

    setAttendanceData(); // 출석 데이터 세팅
  }

  // 출석 데이터 세팅
  void setAttendanceData() {
    if (kDebugMode) print('set Attendance Data!');
    final DateTime lastAttendanceDate = GlobalData.loginUser.attendances.last.time; // 마지막 데이터 출석 날짜

    // 오늘 날짜와 마지막 데이터의 날짜 세팅 (계산하기 편하게 day 까지만)
    firstChartDate = DateTime(now.year, now.month, now.day);
    lastChartDate = DateTime(lastAttendanceDate.year, lastAttendanceDate.month, lastAttendanceDate.day);

    // 오늘 날짜와 가장 마지막 데이터가 몇 일 차이 나는지
    differDays = firstChartDate.difference(lastChartDate).inDays;

    attendanceHistoryList = List.generate(differDays + 1, (index) => AttendanceHistoryData(time: firstChartDate.subtract(Duration(days: index)), attendanceList: []));

    for (int i = 0; i < GlobalData.loginUser.attendances.length; i++) {
      final Attendance attendance = GlobalData.loginUser.attendances[i];
      final DateTime currentDate = attendance.time; // 현재 날자
      final int idx = firstChartDate.difference(DateTime(currentDate.year, currentDate.month, currentDate.day)).inDays; // 첫 번째 데이터와 전 데이터의 차이로 index 구하기

      attendanceHistoryList[idx < 0 ? 0 : idx].attendanceList.insert(0, attendance);
      if (now.year == currentDate.year && now.month == currentDate.month) setAttendanceStatus(attendance.type); // 같은 달인 경우 출결 현황 세팅
    }

    setQRStatus(attendanceHistoryList.first.attendanceList); // 오늘 출결 정보로 qr 세팅
    attendanceHistoryList.insert(0, AttendanceHistoryData.dummyAttendanceHistoryData); // 맨 앞에 더미 데이터 하나
  }

  // QR 세팅 (등원, 하원, 외출, 복귀)
  void setQRStatus(List<Attendance> attendances) {
    int attendanceStatus = attendanceQRStatus.value;
    int outingStatus = outingQRStatus.value;

    for (int i = 0; i < attendances.length; i++) {
      final Attendance attendance = attendances[i];

      switch (attendance.type) {
        case Attendance.typeAttendance: // 등원
          attendanceStatus = qrStatusLeave;
          break;
        case Attendance.typeEarlyAttendance: // 이른 등원
          attendanceStatus = qrStatusLeave;
          break;
        case Attendance.typeUnauthorizedLateness: // 무단 지각
          attendanceStatus = qrStatusLeave;
          break;
        case Attendance.typeLateness: // 사유 지각
          attendanceStatus = qrStatusLeave;
          break;
        case Attendance.typeReAttendance: // 재등원
          attendanceStatus = qrStatusLeave;
          break;
        case Attendance.typeUnauthorizedOuting: // 무단 외출
          outingStatus = qrStatusReturn;
          break;
        case Attendance.typeOuting: // 사유 외출
          outingStatus = qrStatusReturn;
          break;
        case Attendance.typeOutingReturn: // 외출 복귀
          outingStatus = qrStatusOuting;
          break;
        case Attendance.typeUnauthorizedEarlyLeave: // 무단 조퇴
          attendanceStatus = qrStatusAttendance;
          break;
        case Attendance.typeEarlyLeave: // 사유 조퇴
          attendanceStatus = qrStatusAttendance;
          break;
        case Attendance.typeLeave: // 하원
          attendanceStatus = qrStatusAttendance;
          break;
      }
    }

    attendanceQRStatus(attendanceStatus);
    outingQRStatus(outingStatus);
  }

  // 출결 현황 세팅
  void setAttendanceStatus(int type) {
    switch (type) {
      case Attendance.typeAttendance: // 등원
        attendanceCount++; // 출석
        break;
      case Attendance.typeEarlyAttendance: // 이른 등원
        attendanceCount++; // 출석
        break;
      case Attendance.typeUnauthorizedLateness: // 무단 지각
        attendanceCount++; // 출석
        latenessCount++; // 지각
        break;
      case Attendance.typeLateness: // 사유 지각
        attendanceCount++; // 출석
        latenessCount++; // 지각
        break;
      case Attendance.typeUnauthorizedOuting: // 무단 외출
        outingCount++; // 외출
        break;
      case Attendance.typeOuting: // 사유 외출
        outingCount++; // 외출
        break;
      case Attendance.typeUnauthorizedEarlyLeave: // 무단 조퇴
        earlyLeaveCount++; // 조퇴
        break;
      case Attendance.typeEarlyLeave: // 사유 조퇴
        earlyLeaveCount++; // 조퇴
        break;
      case Attendance.typeUnauthorizedAbsent: // 무단 결석
        absentCount++; // 결석
        break;
      case Attendance.typeAbsent: // 사유 결석
        absentCount++; // 결석
        break;
    }
  }

  // 화면에 따른 그래프 처리
  void listenableFunc({required int start, required int end}) {
    if (attendanceHistoryList.isNotEmpty) {
      final int idx = start + 1 >= attendanceHistoryList.length ? attendanceHistoryList.length - 1 : start + 1;
      selectedIndex(idx); // 선택된 index 세팅

      // 대시보드 스크롤 맨밑으로
      if (allowScrollControl && dashboardScrollController.hasClients) {
        dashboardScrollController.animateTo(
          dashboardScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    }
  }

  // 출석 데이터 재요청 (QR 나온 뒤)
  Future<void> resetAttendances() async {
    // state 최신화
    Student? student = await StudentRepository.selectDetail(userID: GlobalData.loginUser.id);
    if(student != null) GlobalData.loginUser.state = student.state;

    GlobalData.loginUser.attendances = await AttendanceRepository.selectByUserID(userID: GlobalData.loginUser.id); // 출석 데이터 최신화

    attendanceCount = 0; // 출석
    latenessCount = 0; // 지각
    earlyLeaveCount = 0; // 조퇴
    outingCount = 0; // 외출
    absentCount = 0; // 결석
    setAttendanceData(); // 출석 데이터 가공
    
    blockScroll(); // 스크롤 0.5초 이후부터 가능하도록
    update();
  }

  // 선택된 인덱스 세팅
  void setSelectedIndex(int index) {
    selectedIndex(index);
    // if (itemScrollController.isAttached) itemScrollController.scrollTo(index: selectedIndex.value, duration: const Duration(milliseconds: 200), alignment: 0.1); // 날짜 스크롤 이동

    // 대시보드 스크롤 맨밑으로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dashboardScrollController.hasClients) {
        dashboardScrollController.animateTo(
          dashboardScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // 스크롤 컨트롤 0.5초 후부터 가능하도록
  void blockScroll(){
    allowScrollControl = false;
    Future.delayed(const Duration(milliseconds: 500), () => allowScrollControl = true);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/repository/attendance_repository.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/model/absence.dart';

class ExceptionRequestController extends GetxController {
  static get to => Get.find<ExceptionRequestController>();

  static const int vacationTicketNull = 0; // 안씀
  static const int vacationTicketOuting = 1; // 외출권
  static const int vacationTicketHalfVacation = 2; // 반휴권
  static const int vacationTicketVacation = 3; // 휴가권

  final PageController pageController = PageController();
  final TextEditingController textEditingController = TextEditingController();

  final List<String> listTabItemTitle = ['개별', '정기'];
  final List<double> listTabItemWidth = [26 * sizeUnit, 26 * sizeUnit];

  final List<String> dayOfWeekList = ['전체 선택', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];

  int barIndex = 0;

  bool get isIndividual => barIndex == 0; // 개별인지

  RxInt exception = nullInt.obs; // 예외
  late Rx<DateTime> startDateTime; // 시작 날짜
  late Rx<DateTime> endDateTime; // 종료 날짜
  RxInt vacationTicket = vacationTicketNull.obs; // 휴가권
  RxString reason = ''.obs; // 사유
  RxList<String> daysOfWeek = <String>[].obs; // 요일

  RxBool get individualIsOk => (exception.value != nullInt && (startDateTime.value.difference(endDateTime.value).inMinutes <= 0) && reason.value.isNotEmpty).obs; // 개별

  RxBool get periodicIsOk => (exception.value != nullInt && daysOfWeek.isNotEmpty && (startDateTime.value.difference(endDateTime.value).inMinutes <= 0) && reason.value.isNotEmpty).obs; // 정기

  RxBool get isOk => isIndividual ? individualIsOk : periodicIsOk;

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
    textEditingController.dispose();
  }

  void initState() {
    // 시작 날짜, 종료 날짜 세팅
    final DateTime now = DateTime.now();
    startDateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute).obs;
    endDateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute).obs;
  }

  // 예외 신청
  Future<void> requestException() async {
    var res = await AttendanceRepository.registerAbsence(
      userID: GlobalData.loginUser.id,
      withVacation: vacationTicket.value,
      type: exception.value,
      periodStart: startDateTime.value.toString(),
      periodEnd: endDateTime.value.toString(),
      reason: reason.value,
    );

    if (res != null) {
      // 상점이 부족한 경우
      if (res == false) {
        String ticket = '외출권';

        switch (vacationTicket.value) {
          case vacationTicketHalfVacation:
            ticket = '반휴권';
            break;
          case vacationTicketVacation:
            ticket = '휴가권';
            break;
        }

        GlobalFunction.showToast(msg: '$ticket을 사용할 상점이 부족합니다.');
      } else {
        GlobalFunction.showToast(msg: '예외 신청이 완료되었습니다.');
        Get.back(); // 대시보드로 이동
      }
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 정기 예외 신청
  Future<void> requestRegularException() async {
    bool monday = false;
    bool tuesday = false;
    bool wednesday = false;
    bool thursday = false;
    bool friday = false;
    bool saturday = false;
    bool sunday = false;

    // 선택된 요일 체크
    for (String element in daysOfWeek) {
      if (element == '전체 선택') {
        monday = true;
        tuesday = true;
        wednesday = true;
        thursday = true;
        friday = true;
        saturday = true;
        break;
      }

      switch (element) {
        case '월요일':
          monday = true;
          break;
        case '화요일':
          tuesday = true;
          break;
        case '수요일':
          wednesday = true;
          break;
        case '목요일':
          thursday = true;
          break;
        case '금요일':
          friday = true;
          break;
        case '토요일':
          saturday = true;
          break;
        case '일요일':
          sunday = true;
          break;
      }
    }

    var res = await AttendanceRepository.registerRegularAbsence(
      userID: GlobalData.loginUser.id,
      type: exception.value,
      periodStart: DateFormat('HH:mm').format(startDateTime.value),
      periodEnd: DateFormat('HH:mm').format(endDateTime.value),
      reason: reason.value,
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday,
    );

    if (res != null) {
      GlobalFunction.showToast(msg: '정기 신청이 완료되었습니다.');
      Get.back(); // 대시보드로 이동
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 페이지 변경
  void pageChange(int index) {
    barIndex = index;
    exception(nullInt); // 예외 초기화
    update();
  }

  // 예외 변경
  void exceptionChange(int type) {
    vacationTicket(vacationTicketNull); // 휴가권 안씀
    exception(type);

    // 결석인 경우 처리
    if (type == (isIndividual ? Absence.typeAbsent : AbsenceRegular.typeAbsent)) {
      startDateTime(DateTime(startDateTime.value.year, startDateTime.value.month, startDateTime.value.day));
      endDateTime(DateTime(endDateTime.value.year, endDateTime.value.month, endDateTime.value.day));
    }
  }

  // 휴가권 사용
  void checkVacationTicket(int type) {
    if (vacationTicket.value == type) {
      vacationTicket(vacationTicketNull);
    } else {
      vacationTicket(type);
    }

    if (type == vacationTicketOuting) {
      endDateTimeAddAtStartTime(addDuration: const Duration(minutes: 90)); // 외출권 사용시 시작 시간에서 90분 더하기
    } else if (type == vacationTicketHalfVacation) {
      endDateTimeAddAtStartTime(addDuration: const Duration(hours: 5)); // 반휴권 사용시 시작 시간에서 5시간 더하기
    }
  }

  // 종료 시간 시작 시간에서 더하기
  void endDateTimeAddAtStartTime({required Duration addDuration}) {
    endDateTime.value = startDateTime.value.add(addDuration);
  }

  // 요일 선택 토글
  void dayOfWeekToggle(String dayOfWeek) {
    if (dayOfWeek == '전체 선택') {
      // 전체 선택인 경우
      if (daysOfWeek.length == dayOfWeekList.length) {
        // 전체 선택 해제
        daysOfWeek.clear();
      } else {
        // 전체 선택 활성화
        daysOfWeek.clear();
        daysOfWeek.addAll(dayOfWeekList);
      }
    } else {
      // 전체 선택이 아닌 경우
      if (daysOfWeek.contains(dayOfWeek)) {
        // 이미 포함되어 있는 요일이면 삭제
        daysOfWeek.remove(dayOfWeek);
        if (daysOfWeek.length == dayOfWeekList.length - 1) daysOfWeek.remove('전체 선택');
      } else {
        // 포함되어 있지 않은 요일이면 추가
        daysOfWeek.add(dayOfWeek);
        if (daysOfWeek.length == dayOfWeekList.length - 1) daysOfWeek.insert(0, '전체 선택');
      }
    }
  }
}

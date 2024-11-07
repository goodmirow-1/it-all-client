import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/dashboard/controller/dashboard_controller.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/data/model/absence.dart';
import 'package:itall_app/repository/attendance_repository.dart';

import '../../config/global_widgets/global_widget.dart';

class ExceptionCheckPageController extends GetxController {
  static get to => Get.find<ExceptionCheckPageController>();

  final PageController pageController = PageController();

  int barIndex = 0;
  List<String> listTabItemTitle = ['개별', '정기'];
  List<double> listTabItemWidth = [26 * sizeUnit, 26 * sizeUnit];
  RxList<int> showReasonList = <int>[].obs; // 사유 보여주는 아이템 리스트
  List<Absence> absenceList = [];
  List<AbsenceRegular> regularAbsenceList = [];
  bool loading = true;

  int individualExceptionCount = 0; // 개별 사유확인 개수
  int regularExceptionCount = 0; // 정기 사유확인 개수

  bool get isIndividual => barIndex == 0; // 개별인지

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  Future<void> initState() async {
    absenceList = await getAbsence(); // 개별 예외
    regularAbsenceList = await getRegularAbsence(); // 정기 예외

    loading = false;
    update();
  }

  // 개별 예외 가져오기
  Future<List<Absence>> getAbsence() async {
    final DateTime now = DateTime.now();
    final List<Absence> list = await AttendanceRepository.selectAbsenceByUserID(userID: GlobalData.loginUser.id);
    int nullCount = 0;

    for (int i = 0; i < list.length; i++) {
      final Absence absence = list[i];
      final bool timeOver = absence.periodStart.difference(now).inMinutes <= 0;

      if (!timeOver && absence.acception == null) nullCount++;
    }

    individualExceptionCount = nullCount;
    if (individualExceptionCount > 0) listTabItemTitle[0] = '개별($individualExceptionCount)';

    return list;
  }

  // 정기 예외 가져오기
  Future<List<AbsenceRegular>> getRegularAbsence() async {
    final List<AbsenceRegular> list = await AttendanceRepository.selectRegularAbsenceByUserID(userID: GlobalData.loginUser.id);
    int nullCount = 0;

    for (int i = 0; i < list.length; i++) {
      final AbsenceRegular absenceRegular = list[i];
      if (absenceRegular.acception == null) nullCount++;
    }

    regularExceptionCount = nullCount;
    if (regularExceptionCount > 0) listTabItemTitle[1] = '정기($regularExceptionCount)';

    return list;
  }

  // 예외처리
  Future<void> modifyAccenption({required exception, required bool acception, bool isEnd = false}) async {
    var result = await AttendanceRepository.modifyAcception(
      isRegular: !isIndividual,
      id: exception.id,
      userID: GlobalData.loginUser.id,
      acception: acception,
    );

    if(result != null) {
      // 리스트에있는 객체 반려, 확인 처리
      if(isIndividual) {
        // 개별
        for(int i = 0; i < absenceList.length; i++) {
          final Absence absence = absenceList[i];
          if(absence.id == exception.id) absence.acception = acception;
        }

        // 사유확인 개수 처리
        if(individualExceptionCount > 0) individualExceptionCount--;
        listTabItemTitle[0] = individualExceptionCount > 0 ? '개별($individualExceptionCount)' : '개별';
      } else {
        // 정기
        for(int i = 0; i < regularAbsenceList.length; i++) {
          final AbsenceRegular absenceRegular = regularAbsenceList[i];
          if(absenceRegular.id == exception.id) absenceRegular.acception = acception;
        }

        // 사유확인 개수 처리 (종료 버튼이면 개수 안뺌)
        if(regularExceptionCount > 0 && !isEnd) regularExceptionCount--;
        listTabItemTitle[1] = regularExceptionCount > 0 ? '정기($regularExceptionCount)' : '정기';
      }

      GlobalData.exceptionCheckCount = individualExceptionCount + regularExceptionCount; // 사유확인 개수 처리

      DashboardController.to.update();
      update();
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 페이지 전환
  void pageChange(int index) {
    showReasonList.clear();
    barIndex = index;
    update();
  }

  // 사유 토글
  void reasonToggle(int id) {
    for (int i = 0; i < showReasonList.length; i++) {
      final element = showReasonList[i];
      if (element == id) {
        showReasonList.removeAt(i);
        return;
      }
    }

    showReasonList.add(id);
  }
}

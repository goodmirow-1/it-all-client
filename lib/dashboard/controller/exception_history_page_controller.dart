import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/data/model/absence.dart';
import 'package:itall_app/repository/attendance_repository.dart';

import '../../config/global_widgets/global_widget.dart';

class ExceptionHistoryPageController extends GetxController {
  static get to => Get.find<ExceptionHistoryPageController>();

  final PageController pageController = PageController();

  int get absenceCheckCount => 0;

  int barIndex = 0;
  List<String> listTabItemTitle = ['개별', '정기'];
  List<double> listTabItemWidth = [26 * sizeUnit, 26 * sizeUnit];
  RxList<int> showReasonList = <int>[].obs; // 사유 보여주는 아이템 리스트
  List<Absence> absenceList = [];
  List<AbsenceRegular> regularAbsenceList = [];
  bool loading = true;

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  Future<void> initState() async{
    absenceList = await AttendanceRepository.selectAbsenceByUserID(userID: GlobalData.loginUser.id); // 개별 예외
    regularAbsenceList = await AttendanceRepository.selectRegularAbsenceByUserID(userID: GlobalData.loginUser.id); // 정기 예외

    loading = false;
    update();
  }

  // 페이지 전환
  void pageChange(int index) {
    showReasonList.clear();
    barIndex = index;
    update();
  }

  // 사유 토글
  void reasonToggle(int id){
    for(int i = 0; i < showReasonList.length; i++) {
      final element = showReasonList[i];
      if(element == id) {
        showReasonList.removeAt(i);
        return;
      }
    }

    showReasonList.add(id);
  }
}
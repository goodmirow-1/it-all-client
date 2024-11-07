import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/repository/attendance_repository.dart';
import 'package:itall_app/repository/reward_repository.dart';

import '../history_view_page.dart';

class HistoryViewPageController extends GetxController {
  static get to => Get.find<HistoryViewPageController>();

  final PageController pageController = PageController();
  late final String title; // 앱바 타이틀
  late final int type; // 타입

  bool get isReward => type == HistoryViewPage.reward; // 상벌점 OR 공용공간
  List resultList = [];

  bool loading = true;

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  void initState(int type) async {
    this.type = type;

    if (isReward) {
      // 상벌점인 경우
      resultList = await RewardRepository.selectByTargetID(userID: GlobalData.loginUser.id);
    } else {
      // 공용공간인 경우
      resultList = await AttendanceRepository.selectPublicSpaceUseListByUserID(userID: GlobalData.loginUser.id);
    }

    switch (type) {
      case HistoryViewPage.reward:
        title = '상벌점 이력';
        break;
      case HistoryViewPage.commonSpace:
        title = '공용공간 사용 이력';
        break;
    }

    loading = false;
    update();
  }
}

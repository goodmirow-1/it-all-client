import 'package:get/get.dart';

import '../../config/global_function.dart';

class MainPageController extends GetxController {
  static get to => Get.find<MainPageController>();

  int currentIndex = 0;

  void changePage(int index){
    currentIndex = index;
    update();
  }

  Future<bool> onWillPop() {
    if (currentIndex != 0) {
      changePage(0);
      return Future.value(false);
    } else {
      return GlobalFunction.isEnd();
    }
  }
}
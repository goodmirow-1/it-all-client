import 'package:get/get.dart';

import '../../data/model/meal_uses.dart';

class MealApplicationHistoryPageController extends GetxController {
  static get to => Get.find<MealApplicationHistoryPageController>();

  bool isCancelMode = false;

  List<Map<String, dynamic>> applicationHistoryList = List.generate(
      12,
          (index) => {
        'dateTime': DateTime.now().add(Duration(days: index)),
        'mealUses': List.generate(
          2,
              (idx) => MealUses(
            id: idx,
            mealPaymentID: idx,
            userID: idx,
            useDay: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().add(Duration(days: index)).day),
            type: idx.isEven ? MealUses.typeLunch : MealUses.typeDinner,
            state: idx.isEven ? MealUses.stateApplication : MealUses.stateCancel,
            createdAt: DateTime.now().toString(),
            updatedAt: DateTime.now().toString(),
          ),
        ),
      }).reversed.toList();

  // 신청 취소
  void applicationCancel() {
    //todo 이틀 후부터 취소 가능함
    isCancelMode = !isCancelMode;

    if(isCancelMode) {

    } else {

    }

    update();
  }

}
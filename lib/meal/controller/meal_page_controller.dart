import 'package:get/get.dart';
import 'package:itall_app/data/model/meal_uses.dart';

class MealPageController extends GetxController {
  static get to => Get.find<MealPageController>();

  List<String> lunchList = ['밥', '소고기 미역국', '삼치순살조림', '오이소박이', '오징어진미채', '오렌지주스', '690kcal'];
  List<String> dinnerList = ['밥', '김치찌개', '제육볶음dfdfdfdfdf', '묵은지', '시금치', '커피우유', '690kcal'];

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
          });
}

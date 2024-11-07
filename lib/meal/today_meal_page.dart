import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/meal/controller/meal_page_controller.dart';
import 'package:itall_app/meal/meal_page.dart';

import '../config/constants.dart';
import '../config/s_text_style.dart';

class TodayMealPage extends StatelessWidget {
  TodayMealPage({Key? key}) : super(key: key);

  final MealPageController controller = Get.find<MealPageController>();

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: '오늘의 식단'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
            child: Column(
              children: [
                SizedBox(height: 16 * sizeUnit),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 14,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16 * sizeUnit),
                      child: MealPage.todayMealWidget(
                        lunchList: controller.lunchList,
                        dinnerList: controller.dinnerList,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/meal/controller/meal_application_page_controller.dart';

import '../config/constants.dart';
import '../config/s_text_style.dart';

class MealApplicationPage extends StatelessWidget {
  MealApplicationPage({Key? key}) : super(key: key);

  final MealApplicationPageController controller = Get.put(MealApplicationPageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: appBar(context),
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
                    return mealItem(
                      lunchList: controller.lunchList,
                      dinnerList: controller.dinnerList,
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

  // 오늘의 식단
  Container mealItem({required List<String> lunchList, required List<String> dinnerList}) {
    RxBool lunchCheck = false.obs;
    RxBool dinnerCheck = false.obs;

    Column menuListView({required List<String> menuList}) {
      return Column(
        children: List.generate(menuList.length, (index) {
          final String lunch = menuList[index];
          final bool isKcal = index == menuList.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isKcal ? 0 : 8 * sizeUnit),
            child: Text(lunch, style: isKcal ? STextStyle.subTitle4().copyWith(color: iaColorDarkGrey) : STextStyle.subTitle3()),
          );
        }),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [defaultBoxShadow],
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 48 * sizeUnit,
            decoration: BoxDecoration(
              color: iaColorBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8 * sizeUnit)),
            ),
            alignment: Alignment.center,
            child: Text(
              '01월 02일 (월)',
              style: STextStyle.subTitle3().copyWith(color: Colors.white),
            ),
          ),
          SizedBox(height: 12 * sizeUnit),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Obx(() => iaCheckBox(
                        value: lunchCheck.value,
                        label: '점심',
                        labelStyle: STextStyle.headline4(),
                        onChanged: () => lunchCheck.toggle(),
                      )),
                ),
              ),
              Expanded(
                child: Center(
                    child: Obx(
                  () => iaCheckBox(
                    value: dinnerCheck.value,
                    label: '저녁',
                    labelStyle: STextStyle.headline4(),
                    onChanged: () => dinnerCheck.toggle(),
                  ),
                )),
              ),
            ],
          ),
          SizedBox(height: 12 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
            child: Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: const Color(0xFFEFEFEF)),
          ),
          SizedBox(height: 8 * sizeUnit),
          Row(
            children: [
              Expanded(child: menuListView(menuList: lunchList)),
              Expanded(child: menuListView(menuList: dinnerList)),
            ],
          ),
          SizedBox(height: 16 * sizeUnit),
        ],
      ),
    );
  }

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: '식사 신청',
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: Center(
            child: GestureDetector(
              onTap: () => showCustomDialog(description: '잔여 횟수가 부족합니다.'),
              child: Text(
                '신청',
                style: STextStyle.subTitle3().copyWith(color: iaColorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

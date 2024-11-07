import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:intl/intl.dart';
import 'package:itall_app/meal/meal_application_page.dart';
import 'package:itall_app/meal/meal_application_history_page.dart';
import 'package:itall_app/meal/today_meal_page.dart';

import '../config/global_assets.dart';
import '../profile/profile_page.dart';
import 'controller/meal_page_controller.dart';
import '../data/model/meal_uses.dart';

class MealPage extends StatelessWidget {
  MealPage({Key? key}) : super(key: key);

  final MealPageController controller = Get.put(MealPageController());

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
                countAndApplicationButton(), // 잔여 횟수, 식사 신청
                SizedBox(height: 24 * sizeUnit),
                buildTitle(title: '오늘의 식단', onTap: () => Get.to(() => TodayMealPage())),
                SizedBox(height: 16 * sizeUnit),
                // 오늘의 식단
                todayMealWidget(
                  lunchList: controller.lunchList,
                  dinnerList: controller.dinnerList,
                ),
                SizedBox(height: 24 * sizeUnit),
                buildTitle(title: '식사 신청 이력', onTap: () => Get.to(() => MealApplicationHistoryPage())),
                SizedBox(height: 16 * sizeUnit),
                mealHistory(), // 식사 신청 이력
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 식사 신청 이력
  ListView mealHistory() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.applicationHistoryList.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> data = controller.applicationHistoryList[index];
        return Column(
          children: List.generate(data['mealUses'].length, (idx) {
            final MealUses mealUses = data['mealUses'][idx];

            return Padding(
              padding: EdgeInsets.only(bottom: idx == data['mealUses'].length - 1 ? 8 * sizeUnit : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MM월 dd일 (${GlobalFunction.dayOfTheWeekInKorean(DateFormat('EEEE').format(mealUses.useDay))})').format(mealUses.useDay),
                    style: STextStyle.subTitle4().copyWith(color: idx == 0 ? iaColorBlack : Colors.white),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Expanded(
                    child: mealUses.state == MealUses.stateApplication ? applicationBox(type: mealUses.type) : applicationCancelBox(type: mealUses.type),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  // 신청 완료 박스
  Widget applicationBox({required int type}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8 * sizeUnit),
      padding: EdgeInsets.symmetric(vertical: 12 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [defaultBoxShadow],
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      alignment: Alignment.center,
      child: Text('${type == MealUses.typeLunch ? '점심' : '저녁'} 신청 완료', style: STextStyle.subTitle3()),
    );
  }

  // 신청 취소 박스
  Widget applicationCancelBox({required int type}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8 * sizeUnit),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [defaultBoxShadow],
            borderRadius: BorderRadius.circular(8 * sizeUnit),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 9 * sizeUnit,
            height: 42 * sizeUnit,
            decoration: BoxDecoration(
              color: iaColorRed,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8 * sizeUnit),
                bottomLeft: Radius.circular(8 * sizeUnit),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12 * sizeUnit,
          child: Text(
            '${type == MealUses.typeLunch ? '점심' : '저녁'} 신청 취소',
            style: STextStyle.subTitle3().copyWith(color: iaColorRed),
          ),
        ),
      ],
    );
  }

  // 오늘의 식단
  static Container todayMealWidget({required List<String> lunchList, required List<String> dinnerList}) {
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
              Expanded(child: Center(child: Text('점심', style: STextStyle.headline4()))),
              Expanded(child: Center(child: Text('저녁', style: STextStyle.headline4()))),
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

  // 잔여 횟수, 식사 신청
  Row countAndApplicationButton() {
    return Row(
      children: [
        Container(
          width: 123 * sizeUnit,
          height: 48 * sizeUnit,
          padding: EdgeInsets.fromLTRB(12 * sizeUnit, 8 * sizeUnit, 0, 8 * sizeUnit),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8 * sizeUnit),
            boxShadow: const [defaultBoxShadow],
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(
                '잔여\n횟수',
                style: STextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12 * sizeUnit),
              Container(
                width: 2 * sizeUnit,
                height: 32 * sizeUnit,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(2 * sizeUnit),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '23',
                    style: STextStyle.subTitle1().copyWith(
                      fontSize: 24 * sizeUnit,
                      color: iaColorRed,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(width: 16 * sizeUnit),
        Expanded(
          child: iaDefaultButton(
            text: '식사 신청',
            // isBig: true,
            onTap: () => Get.to(() => MealApplicationPage()),
          ),
        ),
      ],
    );
  }

  Row buildTitle({required String title, required GestureTapCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: STextStyle.headline3()),
        GestureDetector(
          onTap: onTap,
          child: Text(
            '더보기',
            style: STextStyle.subTitle3().copyWith(color: iaColorRed),
          ),
        ),
      ],
    );
  }

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: 'MEAL',
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: GestureDetector(
            onTap: () => Get.to(() => ProfilePage()),
            child: SvgPicture.asset(
              GlobalAssets.svgPersonInCircle,
              width: 24 * sizeUnit,
            ),
          ),
        ),
      ],
    );
  }
}

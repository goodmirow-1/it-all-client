import 'package:flutter/material.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/meal/controller/meal_application_history_page_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/constants.dart';
import '../config/global_function.dart';
import '../config/s_text_style.dart';
import 'meal_page.dart';
import '../data/model/meal_uses.dart';

class MealApplicationHistoryPage extends StatelessWidget {
  MealApplicationHistoryPage({Key? key}) : super(key: key);

  final MealApplicationHistoryPageController controller = Get.put(MealApplicationHistoryPageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: GetBuilder<MealApplicationHistoryPageController>(
        builder: (_) {
          return Scaffold(
            appBar: appBar(context),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
              child: ListView.builder(
                itemCount: controller.applicationHistoryList.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data = controller.applicationHistoryList[index];
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 16 * sizeUnit : 0),
                    child: Column(
                      children: List.generate(data['mealUses'].length, (idx) {
                        final MealUses mealUses = data['mealUses'][idx];

                        return Padding(
                          padding: EdgeInsets.only(bottom: idx == data['mealUses'].length - 1 ? 8 * sizeUnit : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idx == 0) ...[
                                Text(
                                  DateFormat('yyyy.MM.dd (${GlobalFunction.dayOfTheWeekInKorean(DateFormat('EEEE').format(mealUses.useDay))})').format(mealUses.useDay),
                                  style: STextStyle.subTitle4().copyWith(color: iaColorRed),
                                ),
                                SizedBox(height: 16 * sizeUnit),
                              ],
                              mealUses.state == MealUses.stateApplication ? applicationBox(type: mealUses.type) : applicationCancelBox(type: mealUses.type),
                            ],
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 신청 완료 박스
  Widget applicationBox({required int type}) {
    RxBool isChecked = false.obs;

    return Stack(
      children: [
        Container(
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
        ),
        if (controller.isCancelMode) ...[
          Positioned(
            top: 9 * sizeUnit,
            left: 12 * sizeUnit,
            child: Obx(() => iaCheckBox(value: isChecked.value, onChanged: () => isChecked.toggle())),
          ),
        ],
      ],
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

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: '식사 신청 이력',
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: Center(
            child: GestureDetector(
              onTap: controller.applicationCancel,
              child: Text(
                controller.isCancelMode ? '완료' : '신청 취소',
                style: STextStyle.subTitle3().copyWith(color: iaColorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

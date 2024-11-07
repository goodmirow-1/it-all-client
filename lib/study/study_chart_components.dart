import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/study/controller/study_chart_controller.dart';
import 'package:intl/intl.dart';

import '../config/global_widgets/global_widget.dart';
import '../data/model/study_chart_data.dart';

class StudyChartComponents {
  // 차트 바
  static Widget chartBar({required StudyChartData studyChartData, required int index}) {
    final StudyChartController controller = Get.find<StudyChartController>();
    final double yAxisTextHeight = 6 * sizeUnit; // y축 시간 글자 height / 2

    return Obx(
      () => TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: (studyChartData.studyTime / 60) / controller.calculateMaxStudyTime((controller.maxStudyTime.value / 60).ceil())),
        duration: controller.barDuration,
        builder: (context, double value, child) {
          final double height = value * controller.barMaxHeight;

          return Obx(() => Stack(
            alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  if (controller.selectedIndex.value == index && studyChartData.studyTime != 0) ...[
                    Positioned(
                      top: -16 * sizeUnit,
                      child: Text(
                        '${(studyChartData.studyTime ~/ 60)}H ${(studyChartData.studyTime % 60)}M',
                        style: STextStyle.headline5().copyWith(fontSize: 12, color: iaColorRed),
                      ),
                    ),
                  ],
                  Container(
                    constraints: BoxConstraints(maxHeight: controller.barMaxHeight - yAxisTextHeight),
                    height: height > yAxisTextHeight ? height - yAxisTextHeight : height,
                    width: 16 * sizeUnit,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20 * sizeUnit),
                      color: index == controller.selectedIndex.value ? iaColorRed : iaColorGrey,
                    ),
                    // child: Text((studyChartData.studyTime / 60).toPrecision(1).toString(), style: STextStyle.subTitle5()),
                  ),
                ],
              ));
        },
      ),
    );
  }

  static Widget xAxisText({required DateTime dateTime, required int index}) {
    final StudyChartController controller = Get.find<StudyChartController>();

    Widget dayWidget() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEEE').format(dateTime).substring(0, 3).toUpperCase(),
            style: STextStyle.subTitle4().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
          ),
          SizedBox(height: 2 * sizeUnit),
          Text(
            DateFormat('dd').format(dateTime),
            style: STextStyle.subTitle3().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
          ),
        ],
      );
    }

    Widget weekWidget() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMMM').format(dateTime).substring(0, 3).toUpperCase(),
            style: STextStyle.subTitle4().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
          ),
          SizedBox(height: 2 * sizeUnit),
          Text(
            '${controller.weekOfMonthForSimple(dateTime)}주차',
            style: STextStyle.subTitle3().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
          ),
        ],
      );
    }

    Widget monthWidget() {
      return Text(
        DateFormat('MMMM').format(dateTime).substring(0, 3).toUpperCase(),
        style: STextStyle.subTitle4().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
      );
    }

    Widget resultWidget() {
      switch (controller.periodIndex) {
        case StudyChartController.periodDay:
          return dayWidget();
        case StudyChartController.periodWeek:
          return weekWidget();
        case StudyChartController.periodMonth:
          return monthWidget();
        default:
          return dayWidget();
      }
    }

    return Obx(() => Container(
          width: controller.periodIndex == StudyChartController.periodWeek ? 42 * sizeUnit : 36 * sizeUnit,
          height: controller.periodIndex == StudyChartController.periodMonth ? 56 * sizeUnit : null,
          padding: EdgeInsets.symmetric(vertical: 10 * sizeUnit),
          decoration: BoxDecoration(
            color: index == controller.selectedIndex.value ? iaColorRed : Colors.transparent,
            borderRadius: BorderRadius.circular(20 * sizeUnit),
          ),
          alignment: Alignment.center,
          child: resultWidget(),
        ));
  }

  // 백그라운드 눈금, y축 기준수
  Positioned backgroundWidget({required bool isGraduation}) {
    final StudyChartController controller = Get.find<StudyChartController>();

    return Positioned(
      top: 0 * sizeUnit,
      child: SizedBox(
        height: controller.barMaxHeight,
        child: Column(
          children: List.generate(
            12,
            (index) {
              return Obx(() {
                int studyTime = controller.calculateMaxStudyTime((controller.maxStudyTime.value / 60).ceil());
                final int yInterval = controller.calculateYInterval(studyTime);

                if (index != 0) studyTime = studyTime - (yInterval * index);
                if (studyTime <= 0) return const SizedBox.shrink();

                return Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Opacity(
                          opacity: isGraduation ? 0.2 : 0.0,
                          child: Container(
                            width: Get.width - 32 * sizeUnit,
                            height: 1 * sizeUnit,
                            color: iaColorDarkGrey,
                          ),
                        ),
                        SizedBox(width: 4 * sizeUnit),
                        Text(
                          studyTime == 0 ? '00' : studyTime.toString(),
                          style: STextStyle.subTitle5().copyWith(color: isGraduation ? Colors.transparent : iaColorDarkGrey),
                        ),
                        SizedBox(width: 16 * sizeUnit),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}

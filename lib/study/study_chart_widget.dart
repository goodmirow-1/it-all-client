import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';

import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/model/study_chart_data.dart';
import 'study_chart_components.dart';
import 'controller/study_chart_controller.dart';

class StudyChartWidget extends StatelessWidget {
  StudyChartWidget({Key? key, required this.itemScrollController, required this.itemPositionsListener}) : super(key: key);

  final StudyChartController controller = Get.find<StudyChartController>();
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudyChartController>(
      initState: (state) => controller.initState(),
      builder: (_) {
        return Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4 * sizeUnit, horizontal: 12 * sizeUnit),
                decoration: BoxDecoration(
                  border: Border.all(color: iaColorBlack),
                  borderRadius: BorderRadius.circular(8 * sizeUnit),
                ),
                child: controller.chartDataList.isEmpty
                    ? Text(
                        DateFormat('MMMM. yyyy').format(DateTime.now()),
                        style: STextStyle.headline5().copyWith(fontSize: 12 * sizeUnit),
                      )
                    : Obx(() => Text(
                          DateFormat('MMMM. yyyy').format(controller.chartDataList[controller.selectedIndex.value].time),
                          style: STextStyle.headline5().copyWith(fontSize: 12 * sizeUnit),
                        )),
              ),
            ),
            SizedBox(height: 8 * sizeUnit),
            indexPositionsView(), // index stream widget
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16 * sizeUnit),
                child: Text('(단위: H)', style: STextStyle.subTitle4().copyWith(color: iaColorDarkGrey)),
              ),
            ),
            SizedBox(height: 4 * sizeUnit),
            SizedBox(
              height: controller.barMaxHeight + 64 * sizeUnit,
              child: Stack(
                children: [
                  StudyChartComponents().backgroundWidget(isGraduation: true), // 배경 줄자
                  chart(), // 차트
                  StudyChartComponents().backgroundWidget(isGraduation: false), // y축 눈금
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 차트
  Widget chart() {
    return ScrollablePositionedList.builder(
      scrollDirection: Axis.horizontal,
      reverse: true,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemCount: controller.chartDataList.length,
      itemBuilder: (context, index) {
        if (index == 0) return SizedBox(width: 30 * sizeUnit);
        final StudyChartData chartData = controller.chartDataList[index];

        return Padding(
          padding: EdgeInsets.only(left: index != controller.chartDataList.length - 1 ? 8 * sizeUnit : Get.width - 70 * sizeUnit),
          child: GestureDetector(
            onTap: () => controller.selectedIndex(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StudyChartComponents.chartBar(
                  index: index,
                  studyChartData: chartData,
                ),
                SizedBox(height: 8 * sizeUnit),
                StudyChartComponents.xAxisText(dateTime: chartData.time, index: index)
              ],
            ),
          ),
        );
      },
    );
  }

  // 화면에 보여지는 index stream widget
  Widget indexPositionsView() {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
        int start = 0; // 시작 index
        int end = 0; // 끝 index

        if (positions.isNotEmpty) {
          start = positions
              .where((ItemPosition position) => position.itemTrailingEdge > 0)
              .reduce((ItemPosition min, ItemPosition position) => position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
              .index;

          end = positions
                  .where((ItemPosition position) => position.itemLeadingEdge < 1)
                  .reduce((ItemPosition max, ItemPosition position) => position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
                  .index +
              1;

          // 스크롤 위치에 따라 처리
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.maxStudyTime(controller.listenableFunc(start: start, end: end));
          });
        }

        return const SizedBox.shrink();
      },
    );
  }
}

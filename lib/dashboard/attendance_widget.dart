import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as Intl;
import 'package:itall_app/dashboard/controller/dashboard_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../config/constants.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/model/attendance.dart';
import '../data/model/attendance_history_data.dart';
import 'attendance_status_page.dart';

class AttendanceWidget extends StatelessWidget {
  AttendanceWidget({Key? key}) : super(key: key);

  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        attendanceStatus(), // 출결 현황
        SizedBox(height: 24 * sizeUnit),
        if (controller.attendanceHistoryList.isNotEmpty) ...[
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4 * sizeUnit, horizontal: 12 * sizeUnit),
              decoration: BoxDecoration(
                border: Border.all(color: iaColorDarkGrey),
                borderRadius: BorderRadius.circular(24 * sizeUnit),
              ),
              child: controller.attendanceHistoryList.isEmpty
                  ? Text(
                      Intl.DateFormat('MMMM. yyyy').format(DateTime.now()),
                      style: STextStyle.headline5().copyWith(fontSize: 12 * sizeUnit),
                    )
                  : Obx(() => Text(
                        Intl.DateFormat('MMMM. yyyy').format(controller.attendanceHistoryList[controller.selectedIndex.value].time),
                        style: STextStyle.headline5().copyWith(fontSize: 12 * sizeUnit),
                      )),
            ),
          ),
          SizedBox(height: 8 * sizeUnit),
          SizedBox(
            height: 64 * sizeUnit,
            child: ScrollablePositionedList.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              initialScrollIndex: 0,
              itemScrollController: controller.itemScrollController,
              itemPositionsListener: controller.itemPositionsListener,
              itemCount: controller.attendanceHistoryList.length,
              itemBuilder: (context, index) {
                if (index == 0) return SizedBox(width: 30 * sizeUnit);
                final AttendanceHistoryData attendancesHistoryData = controller.attendanceHistoryList[index];

                return Padding(
                  padding: EdgeInsets.only(left: index != controller.attendanceHistoryList.length - 1 ? 8 * sizeUnit : Get.width - 70 * sizeUnit),
                  child: GestureDetector(
                    onTap: () => controller.setSelectedIndex(index),
                    child: xAxisText(dateTime: attendancesHistoryData.time, index: index),
                  ),
                );
              },
            ),
          ),
          indexPositionsView(),
          SizedBox(height: 16 * sizeUnit),
          history(),
        ],
      ],
    );
  }

  Widget xAxisText({required DateTime dateTime, required int index}) {
    return Obx(() => Container(
          width: 36 * sizeUnit,
          height: 56 * sizeUnit,
          decoration: BoxDecoration(
            color: index == controller.selectedIndex.value ? iaColorRed : Colors.transparent,
            borderRadius: BorderRadius.circular(20 * sizeUnit),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Intl.DateFormat('EEEE').format(dateTime).substring(0, 3).toUpperCase(),
                style: STextStyle.subTitle4().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
              ),
              SizedBox(height: 2 * sizeUnit),
              Text(
                Intl.DateFormat('dd').format(dateTime),
                style: STextStyle.subTitle3().copyWith(color: index == controller.selectedIndex.value ? Colors.white : iaColorDarkGrey),
              ),
            ],
          ),
        ));
  }

  // 화면에 보여지는 index stream widget
  Widget indexPositionsView() {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: controller.itemPositionsListener.itemPositions,
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

          // 스크롤에 따라 선택 인덱스 바꿔주기
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.listenableFunc(start: start, end: end);
          });
        }

        return const SizedBox.shrink();
      },
    );
  }

  // 기록
  Padding history() {
    // 등하원 박스
    Widget normalBox(Attendance attendance) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16 * sizeUnit),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${Intl.DateFormat('hh:mm').format(attendance.time)} ${Intl.DateFormat.jm().format(attendance.time).split(' ').last}', style: STextStyle.subTitle4()),
            SizedBox(width: 8 * sizeUnit),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12 * sizeUnit),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [defaultBoxShadow],
                  borderRadius: BorderRadius.circular(8 * sizeUnit),
                ),
                child: Text(Attendance.typeToText(attendance.type), style: STextStyle.headline5()),
              ),
            ),
          ],
        ),
      );
    }

    // 예외 박스
    Widget exceptionBox(Attendance attendance) {
      final TextSpan span = TextSpan(
        text: attendance.description!,
        style: STextStyle.body2(),
      );
      final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: (Get.width - 32 - 52 - 8 - 9 - 24) * sizeUnit);
      final int numLines = tp.computeLineMetrics().length;

      return Padding(
        padding: EdgeInsets.only(bottom: 16 * sizeUnit),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Intl.DateFormat('hh:mm').format(attendance.time)} ${Intl.DateFormat.jm().format(attendance.time).split(' ').last}',
              style: STextStyle.subTitle4(),
            ),
            SizedBox(width: 8 * sizeUnit),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [defaultBoxShadow],
                  borderRadius: BorderRadius.circular(8 * sizeUnit),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 9 * sizeUnit,
                      height: (46 + numLines * 18.2) * sizeUnit,
                      decoration: BoxDecoration(
                        color: iaColorRed,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8 * sizeUnit),
                          bottomLeft: Radius.circular(8 * sizeUnit),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * sizeUnit),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12 * sizeUnit),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Attendance.typeToText(attendance.type), style: STextStyle.headline5().copyWith(color: iaColorRed)),
                            SizedBox(height: 4 * sizeUnit),
                            Text(
                              attendance.description!,
                              style: STextStyle.body2(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * sizeUnit),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Obx(() => Column(
            children: List.generate(controller.attendanceHistoryList[controller.selectedIndex.value].attendanceList.length, (index) {
              final Attendance attendance = controller.attendanceHistoryList[controller.selectedIndex.value].attendanceList[index];
              if (attendance.description == null || attendance.description!.isEmpty) {
                return normalBox(attendance);
              } else {
                return exceptionBox(attendance);
              }
            }),
          )),
    );
  }

  // 출결 현황
  Padding attendanceStatus() {
    // 출결 아이템
    Widget attendanceItem({required String label, required int count}) {
      return GestureDetector(
        onTap: () => Get.to(() => AttendanceStatusPage(status: label)),
        child: Container(
          width: 56 * sizeUnit,
          padding: EdgeInsets.all(8 * sizeUnit),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [defaultBoxShadow],
            borderRadius: BorderRadius.circular(8 * sizeUnit),
          ),
          child: Column(
            children: [
              Container(
                width: 40 * sizeUnit,
                height: 40 * sizeUnit,
                decoration: const BoxDecoration(
                  color: iaColorBlack,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: STextStyle.subTitle3().copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 6 * sizeUnit),
              Text(label, style: STextStyle.subTitle3()),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이달의 출결 현황', style: STextStyle.headline3()),
          SizedBox(height: 16 * sizeUnit),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              attendanceItem(label: '출석', count: controller.attendanceCount),
              attendanceItem(label: '지각', count: controller.latenessCount),
              attendanceItem(label: '조퇴', count: controller.earlyLeaveCount),
              attendanceItem(label: '외출', count: controller.outingCount),
              attendanceItem(label: '결석', count: controller.absentCount),
            ],
          ),
        ],
      ),
    );
  }
}

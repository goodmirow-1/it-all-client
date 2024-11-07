import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/data/model/study_chart_data.dart';
import 'package:itall_app/study/controller/study_chart_controller.dart';
import 'package:intl/intl.dart';
import 'package:itall_app/study/controller/study_time_history_controller.dart';

import '../config/constants.dart';
import '../config/s_text_style.dart';

class StudyTimeHistoryPage extends StatelessWidget {
  StudyTimeHistoryPage({Key? key, required this.isThisMonth}) : super(key: key);

  final bool isThisMonth;

  final StudyTimeHistoryController controller = Get.put(StudyTimeHistoryController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(
          context,
          title: '${isThisMonth ? '이번달' : '지난달'} 누적 순공시간 이력',
        ),
        body: GetBuilder<StudyTimeHistoryController>(
            initState: (state) => controller.initState(isThisMonth),
            builder: (_) {
              return ListView.builder(
                itemCount: controller.studyDataList.length,
                itemBuilder: (context, index) => historyItem(
                  studyChartData: controller.studyDataList[index],
                  totalMinute: controller.studyTimeList[index],
                ),
              );
            }),
      ),
    );
  }

  Widget historyItem({required StudyChartData studyChartData, required int totalMinute}) {
    if(studyChartData.studyTime == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16 * sizeUnit),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: iaColorGrey),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy.MM.dd').format(studyChartData.time),
                  style: STextStyle.subTitle4().copyWith(color: iaColorRed),
                ),
                SizedBox(height: 16 * sizeUnit),
                Text(
                  '+ ${studyChartData.studyTime ~/ 60 == 0 ? '' : '${studyChartData.studyTime ~/ 60}시간'}${studyChartData.studyTime % 60 == 0 ? '' : ' ${studyChartData.studyTime % 60}분'}',
                  style: STextStyle.subTitle3(),
                ),
              ],
            ),
          ),
          Text(
            '${totalMinute ~/ 60 == 0 ? '' : '${totalMinute ~/ 60}시간'}${totalMinute % 60 == 0 ? '' : ' ${totalMinute % 60}분'}',
            style: STextStyle.subTitle1(),
          ),
        ],
      ),
    );
  }
}

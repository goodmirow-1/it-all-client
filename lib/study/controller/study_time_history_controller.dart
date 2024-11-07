import 'package:get/get.dart';
import 'package:itall_app/data/model/study_chart_data.dart';
import 'package:itall_app/study/controller/study_chart_controller.dart';
import 'package:jiffy/jiffy.dart';

class StudyTimeHistoryController extends GetxController {
  static get to => Get.find<StudyTimeHistoryController>();

  final StudyChartController studyChartController = Get.find<StudyChartController>();

  List<StudyChartData> studyDataList = [];
  List<int> studyTimeList = [];

  void initState(bool isThisMonth){
    final int monthNum = isThisMonth ? 0 : 1;
    final Jiffy now = Jiffy(DateTime(DateTime.now().year, DateTime.now().month)); // 오늘 날짜
    int totalMinute = 0; // 총 공부 시간

    // 차트 데이터 리스트 세팅
    for(StudyChartData studyChartData in studyChartController.pureStudyTimeList!) {
      final Jiffy dateTime = Jiffy(DateTime(studyChartData.time.year, studyChartData.time.month)); // 차트 데이터의 날짜
      final int diffMonth = now.diff(dateTime, Units.MONTH).toInt();

      if(diffMonth > monthNum) break; // 달 차이나면 break

      if(diffMonth == monthNum) {
        studyDataList.add(studyChartData); // 데이터 add
        totalMinute += studyChartData.studyTime; // 시간 +
      }
    }

    // 총 시간 계산
    for(StudyChartData studyChartData in studyDataList) {
      studyTimeList.add(totalMinute);
      totalMinute -= studyChartData.studyTime;
    }
  }
}
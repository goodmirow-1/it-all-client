import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/repository/study_repository.dart';
import 'package:jiffy/jiffy.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/model/study_chart_data.dart';

class StudyChartController extends GetxController {
  static get to => Get.find<StudyChartController>();

  static const periodDay = 0; // 일
  static const periodWeek = 1; // 주
  static const periodMonth = 2; // 월
  static const int minStudyTime = 360; // 최소로 보여줄 y축 시간

  final double barMaxHeight = 260 * sizeUnit; // 그래프 바 최대 높이
  final Duration barDuration = const Duration(milliseconds: 300); // 그래프 바 duration

  final DateTime now = DateTime.now();
  late final DateTime firstChartDate; // 첫 번째 데이터의 date
  late final DateTime lastChartDate; // 마지막 데이터의 date
  late final int differDays; // 마지막 데이터와 첫번째 데이터의 일수 차이

  List<StudyChartData>? pureStudyTimeList; // 순공시간 데이터 리스트
  int periodIndex = periodDay; // 기간
  RxInt selectedIndex = 0.obs; // 선택된 index
  RxInt maxStudyTime = minStudyTime.obs; // studyTime 최대 값

  List<StudyChartData> get chartDataList => periodIndex == periodDay
      ? chartListForDay
      : periodIndex == periodWeek
          ? chartListForWeek
          : chartListForMonth;

  List<StudyChartData> chartListForDay = []; // 차트 데이터 리스트 (일)
  List<StudyChartData> chartListForWeek = []; // 차트 데이터 리스트 (주)
  List<StudyChartData> chartListForMonth = []; // 차트 데이터 리스트 (월)

  Future<void> initState() async {
    setChart(); // 차트 데이터 세팅
  }

  // 차트 데이터 세팅
  Future<void> setChart() async {
    if (pureStudyTimeList != null) return; // 이미 데이터 세팅 했으면 리턴
    if (kDebugMode) print('set chart data!');

    // 순공시간 리스트 불러오기
    pureStudyTimeList = await StudyRepository.selectListByUserID(userID: GlobalData.loginUser.id);
    if (pureStudyTimeList!.isEmpty) return; // 데이터가 없다면 리턴

    final DateTime lastDataDate = pureStudyTimeList!.last.time; // 마지막 데이터의 date

    // 오늘 날짜와 마지막 데이터의 날짜 세팅 (계산하기 편하게 day 까지만)
    firstChartDate = DateTime(now.year, now.month, now.day);
    lastChartDate = DateTime(lastDataDate.year, lastDataDate.month, lastDataDate.day);

    // 오늘 날짜와 가장 마지막 데이터가 몇 일 차이 나는지
    differDays = firstChartDate.difference(lastChartDate).inDays;

    setDataForDay(); // 데이터 세팅 (일 그래프)
    setDataForWeek(); // 데이터 세팅 (주 그래프)
    setDataForMonth(); // 데이터 세팅 (월 그래프)
    update();
  }

  // 데이터 세팅 (일 그래프)
  void setDataForDay() {
    chartListForDay = List.generate(differDays + 1, (index) => StudyChartData(studyTime: 0, time: firstChartDate.subtract(Duration(days: index))));

    for (int i = 0; i < pureStudyTimeList!.length; i++) {
      final StudyChartData studyChartData = pureStudyTimeList![i];
      final DateTime currentDate = studyChartData.time; // 현재 데이터의 날자
      final int idx = firstChartDate.difference(DateTime(currentDate.year, currentDate.month, currentDate.day)).inDays; // 첫 번째 데이터와 전 데이터의 차이로 index 구하기

      chartListForDay[idx].studyTime += studyChartData.studyTime; // 순공시간 날짜에 맞게 더해주기
    }

    chartListForDay.insert(0, StudyChartData(studyTime: 0, time: now)); // 맨 앞에 더미 데이터 하나
  }

  // 데이터 세팅 (주 그래프)
  void setDataForWeek() {
    final int diff = firstChartDate.weekday - DateTime.monday; // 첫 번째 데이터의 요일과 그 주의 월요일까지의 차
    final int num = 1 + ((differDays - diff) ~/ 7) + ((differDays - diff) % 7 > 0 ? 1 : 0); // index 몇 개 나오는지 계산

    // 각 주의 월요일을 시간에 집어넣는다
    chartListForWeek = List.generate(
      num,
      (index) => StudyChartData(
        studyTime: 0,
        time: firstChartDate.subtract(Duration(days: diff)).subtract(Duration(days: 7 * (index))),
      ),
    );

    final DateTime firstDate = chartListForWeek.first.time;

    for (int i = 0; i < pureStudyTimeList!.length; i++) {
      final StudyChartData studyChartData = pureStudyTimeList![i];
      final DateTime currentDate = DateTime(studyChartData.time.year, studyChartData.time.month, studyChartData.time.day); // 현재 데이터의 날짜
      final DateTime currentDateMonday = currentDate.subtract(Duration(days: currentDate.weekday - DateTime.monday)); // 현재 데이터의 날짜가 해당하는 주의 월요일
      final int idx = firstDate.difference(currentDateMonday).inDays ~/ 7;

      chartListForWeek[idx].studyTime += studyChartData.studyTime;
    }

    chartListForWeek.insert(0, StudyChartData(studyTime: 0, time: now)); // 맨 앞에 더미 데이터 하나
  }

  // 데이터 세팅 (월 그래프)
  void setDataForMonth() {
    final Jiffy firstMonth = Jiffy(DateTime(firstChartDate.year, firstChartDate.month)); // 처음 데이터의 dateTime
    final int differMonth = firstMonth.diff(DateTime(lastChartDate.year, lastChartDate.month), Units.MONTH).toInt(); // 첫 달과 마지막 달 개월 수 차이
    chartListForMonth = List.generate(differMonth + 1, (index) => StudyChartData(studyTime: 0, time: Jiffy([firstMonth.year, firstMonth.month]).subtract(months: index).dateTime));

    for (int i = 0; i < pureStudyTimeList!.length; i++) {
      final StudyChartData studyChartData = pureStudyTimeList![i];
      final DateTime currentDate = DateTime(studyChartData.time.year, studyChartData.time.month); // 현재 데이터의 날자
      final int idx = firstMonth.diff(currentDate, Units.MONTH).toInt(); // 이전 데이터와 처음 데이터의 월 차이

      chartListForMonth[idx].studyTime += studyChartData.studyTime; // 순공시간 날짜에 맞게 더해주기
    }

    chartListForMonth.insert(0, StudyChartData(studyTime: 0, time: now)); // 맨 앞에 더미 데이터 하나
  }

  // 기간 세팅
  void changePeriod(int index, {required ItemScrollController itemScrollController}) {
    periodIndex = index;
    selectedIndex(0);

    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => itemScrollController.jumpTo(index: 0));
  }

  // 화면에 따른 그래프 처리
  int listenableFunc({required int start, required int end}) {
    int resultMaxStudyTime = minStudyTime;

    if (chartDataList.isNotEmpty) {
      final int idx = start + 1 >= chartDataList.length ? chartDataList.length - 1 : start + 1;
      selectedIndex(idx); // 선택된 index 세팅

      // 최대 시간 계산
      for (int i = 0; i < end - start; i++) {
        final int idx = start + i >= chartDataList.length ? chartDataList.length - 1 : start + i;
        final StudyChartData chartData = chartDataList[idx];
        if (resultMaxStudyTime < chartData.studyTime) resultMaxStudyTime = calculateMaxStudyTime(chartData.studyTime);
      }
    }

    return resultMaxStudyTime;
  }

  // 월 주차. (첫 번째 월요일이 1주차 시작).
  int weekOfMonthForSimple(DateTime date) {
    // 월의 첫번째 날짜.
    DateTime firstDay = DateTime(date.year, date.month, 1);

    // 월중에 첫번째 월요일인 날짜.
    DateTime firstMonday = firstDay.add(Duration(days: (DateTime.monday + 7 - firstDay.weekday) % 7));

    // 첫번째 날짜와 첫번째 월요일인 날짜가 동일한지 판단.
    // 동일할 경우: 1, 동일하지 않은 경우: 2 를 마지막에 더한다.
    // final bool isFirstDayMonday = firstDay == firstMonday;

    final int different = calculateDaysBetween(from: firstMonday, to: date);
    // final int different = calculateDaysBetween(from: firstDay, to: date);

    // 주차 계산.
    // int weekOfMonth = (different / 7 + (isFirstDayMonday ? 1 : 2)).toInt();
    int weekOfMonth = (different / 7 + 1).toInt();
    return weekOfMonth;
  }

  // D-Day 계산.
  int calculateDaysBetween({required DateTime from, required DateTime to}) {
    return (to.difference(from).inHours / 24).round();
  }

  // y축 간격 계산
  int calculateYInterval(int studyTime) {
    if (studyTime < 10) {
      return 1;
    } else if (studyTime < 20) {
      return 2;
    } else if (studyTime < 50) {
      return 5;
    } else if (studyTime < 100) {
      return 10;
    } else if (studyTime <= 200) {
      return 20;
    } else if (studyTime <= 450) {
      return 50;
    } else {
      return (studyTime ~/ 12 + 100) ~/ 100 * 100; // 보조선 갯수만큼 나눈 뒤 10의 자리에서 올림
    }
  }

  // y축 보조선 최대 값 계산 함수
  int calculateMaxStudyTime(int studyTime) {
    if (studyTime >= 100) {
      return (studyTime + 10) ~/ 10 * 10; // 1의 자리에서 올림
    } else if (studyTime >= 20) {
      final int ceilInt = (studyTime + 10) ~/ 10 * 10; // 1의 자리에서 올림

      if (ceilInt - studyTime < 5) {
        return ceilInt;
      } else {
        return ceilInt - 5; // 1의 자리에서 올림 - 5
      }
    } else {
      return studyTime;
    }
  }
}

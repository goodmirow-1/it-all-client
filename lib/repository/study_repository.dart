import 'dart:convert';

import '../data/model/pure_study_ranking.dart';
import '../data/model/study_chart_data.dart';
import '../network/ApiProvider.dart';

class StudyRepository {
  static const String defaultURL = '/PureStudy';

  // 순공시간 랭킹 가져오기
  static Future<List<PureStudyRanking>> selectRank({required int centerID, required bool isThisMonth, required int userID}) async {
    List<PureStudyRanking> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/Rank',
        jsonEncode({
          "centerID": centerID,
          "isThisMonth": isThisMonth ? 1 : 0,
          "userID": userID,
        }));

    if(res != null) {
      for(int i = 0; i < res.length; i++) {
        list.add(PureStudyRanking.fromJson(res[i]));
      }
    }

    return list;
  }

  // 지난달 순공시간 가져오기
  static Future<int> selectLastMonthTime({required int userID}) async {
    int minute = 0;

    var res = await ApiProvider().post(
        '$defaultURL/Select/LastMonthTime',
        jsonEncode({
          "userID": userID,
        }));

    if(res != null && res.isNotEmpty) {
      minute = res[0]['Time'];
    }

    return minute;
  }

  // 순공시간 리스트 가져오기
  static Future<List<StudyChartData>> selectListByUserID({required int userID}) async {
    List<StudyChartData> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/List/By/UserID',
        jsonEncode({
          "userID": userID,
        }));

    if(res != null) {
      for(int i = 0; i < res.length; i++) {
        list.add(StudyChartData.fromJson(res[i]));
      }
    }

    return list;
  }
}
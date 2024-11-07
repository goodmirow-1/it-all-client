import 'dart:convert';

import 'package:itall_app/data/model/reward.dart';

import '../network/ApiProvider.dart';

class RewardRepository {
  static const String defaultURL = '/Reward';

  // 상점 이력 가져오기
  static Future<List<Reward>> selectByTargetID({required int userID}) async {
    List<Reward> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/By/TargetID',
        jsonEncode({
          "userID": userID,
        }));

    if(res != null) {
      for(int i = 0; i < res.length; i++) {
        list.add(Reward.fromJson(res[i]));
      }
    }

    return list;
  }
}
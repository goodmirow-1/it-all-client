import 'dart:convert';

import 'package:itall_app/data/global_data.dart';

import '../data/model/notice.dart';
import '../network/ApiProvider.dart';

class BoardRepository {
  static const String defaultURL = '/Board';

  // 공지 리스트 가져오기
  static Future<List<Notice>> selectList() async{
    List<Notice> list = [];

    var res = await ApiProvider().post(
        '$defaultURL/Select/List/By/CenterID',
        jsonEncode({
          "type": Notice.typeStudent,
          "centerID" : GlobalData.loginUser.centerID
        }));

    if(res != null && res != false) {
      for(int i = 0; i < res.length; i++) {
        list.add(Notice.fromJson(res[i]));
      }
    }

    return list;
  }
}
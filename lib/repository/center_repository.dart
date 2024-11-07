import 'dart:convert';

import '../network/ApiProvider.dart';

class CenterRepository {
  static const String defaultURL = '/Center';

  // 센터 리스트 가져오기
  static Future<List<Map<String, dynamic>>> selectList() async {
    List<Map<String, dynamic>> list = [];

    var res = await ApiProvider().post(
      '$defaultURL/Select/List',
      jsonEncode({}),
    );

    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        final dynamic result = res[i];
        list.add({
          'id': result['id'],
          'name': result['Name'],
        });
      }
    }

    return list;
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';

import '../data/model/student.dart';
import '../network/ApiProvider.dart';

class StudentRepository {
  static const String defaultURL = '/Student';

  // 로그인
  static Future<dynamic> login({required int number, required String password, required bool isParentLogin}) async {
    var res = await ApiProvider().post(
        '$defaultURL/Login',
        jsonEncode({
          "number": number,
          "password": password,
          "isParentLogin": isParentLogin ? 1 : 0, // 0: 학생, 1: 학부모
        }));

    return res;
  }

  // 로그아웃
  static Future<bool?> logout({required int userID, required String token}) async {
    bool? res = await ApiProvider().post(
        '$defaultURL/Logout',
        jsonEncode({
          "userID": userID,
          "token": token,
        }));

    return res;
  }

  // 비밀번호 수정
  static Future<dynamic> modifyPassword({required int number, required String password, required bool isParent}) async {
    var res = await ApiProvider().post(
        '$defaultURL/Modify/Password',
        jsonEncode({
          "number": number,
          "password": password,
          "isParent": isParent,
        }));

    return res;
  }

  // 학생 디테일 정보 가져오기
  static Future<Student?> selectDetail({required int userID}) async {
    var res = await ApiProvider().post(
        '$defaultURL/Select/Detail',
        jsonEncode({
          "userID": userID,
        }));

    if (res != null) {
      return Student.fromJson(res['student']);
    }

    return res;
  }

  // 프로필 이미지 수정
  static Future<String?> modifyProfileImage({required FormData formData}) async {
    final Dio dio = Dio();

    Response response = await dio.post(
      '${ApiProvider().getUrl}$defaultURL/Modify/ProfileImage',
      data: formData,
    );

    if(response.data != null) {
      return '${ApiProvider().getImgUrl}/${response.data}';
    } else {
      return null;
    }
  }
}

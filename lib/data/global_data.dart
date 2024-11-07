import 'package:get/get.dart';
import 'package:itall_app/data/model/student.dart';

import '../config/constants.dart';
import 'model/pure_study_ranking.dart';

class GlobalData {
  static Student loginUser = Student.nullStudent;
  static bool isParents = false; // 학부모 로그인
  static String accessToken = '';
  static int studyingCount = 0; // 공부중인 학생
  static int exceptionCheckCount = 0; // 사유확인 개수

  static Rx<String> dDay = ''.obs; // 디데이
  static Rx<String> dDayText = ''.obs; // 디데이 문구

  static DateTime? currentBackPressTime; // 앱 종료 체크용

  static void resetData(){
    loginUser = Student.nullStudent;
    isParents = false;
    accessToken = '';
    studyingCount = 0;
    dDay('');
    dDayText('');
    exceptionCheckCount = 0;
  }
}

import 'package:get/get.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/home/main_page.dart';
import 'package:itall_app/repository/student_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordSettingController extends GetxController {
  static get to => Get.find<PasswordSettingController>();

  RxString password = ''.obs; // 비밀번호
  RxString verifyPassword = ''.obs; // 비밀번호 확인

  RxBool get isOk => (password.value.length >= 8 && verifyPassword.value == password.value).obs;

  // 비밀번호 세팅
  Future<void> setPassword(String id) async {
    GlobalFunction.loadingDialog(); // 로딩 시작

    var res = await StudentRepository.modifyPassword(
      number: GlobalData.loginUser.number,
      password: password.value,
      isParent: GlobalData.isParents,
    );

    if (res != null) {
      final prefs = await SharedPreferences.getInstance();

      // 자동 로그인 데이터 세팅
      prefs.setString('id', id);
      prefs.setString('password', password.value);
      Get.offAll(() => MainPage());
    } else {
      Get.back(); // 로딩 끝
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 비밀번호 에러 텍스트
  String? passwordErrorText() {
    if (password.value.isNotEmpty && password.value.length < 8) {
      return '8자 이상 입력해주세요.';
    } else {
      return null;
    }
  }

  // 비밀번호 확인 에러 텍스트
  String? verifyPasswordErrorText() {
    if (verifyPassword.value.isNotEmpty && password.value != verifyPassword.value) {
      return '비밀번호가 일치하지 않습니다.';
    } else {
      return null;
    }
  }
}

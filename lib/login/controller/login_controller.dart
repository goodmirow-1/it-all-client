import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';

import '../../config/global_function.dart';
import '../../config/global_widgets/global_widget.dart';

class LoginController extends GetxController {
  static get to => Get.find<LoginController>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  onClose() {
    super.onClose();

    idController.dispose();
    passwordController.dispose();
  }

  // 로그인
  Future<void> loginFunc() async {
    GlobalFunction.globalLogin(
      id: kDebugMode
          ? idController.text.isEmpty
              ? '2023001002'
              : idController.text
          : idController.text,
      password: kDebugMode
          ? passwordController.text.isEmpty
              ? '11111111'
              : passwordController.text
          : passwordController.text,
      nullCallback: () => showCustomDialog(
        description: '일치하는 회원정보가 없습니다.\n아이디 또는 비밀번호를 확인해주세요.',
        okColor: iaColorRed,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/global_widgets/custom_text_field.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/login/controller/password_setting_controller.dart';

class PasswordSettingPage extends StatelessWidget {
  PasswordSettingPage({Key? key, required this.id}) : super(key: key);

  final String id; // 자동로그인 세팅하려면 id 필요함

  final PasswordSettingController controller = Get.put(PasswordSettingController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => GlobalFunction.unFocus(context),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                      child: Column(
                        children: [
                          Text(
                            '비밀번호를 설정해주세요.',
                            style: STextStyle.subTitle1().copyWith(fontSize: 20 * sizeUnit),
                          ),
                          SizedBox(height: 24 * sizeUnit),
                          Obx(() => CustomTextField(
                                hintText: '비밀번호',
                                obscureText: true,
                                errorText: controller.passwordErrorText(),
                                onChanged: (p0) => controller.password(p0),
                              )),
                          SizedBox(height: 8 * sizeUnit),
                          Obx(() => CustomTextField(
                                hintText: '비밀번호 확인',
                                obscureText: true,
                                errorText: controller.verifyPasswordErrorText(),
                                onChanged: (p0) => controller.verifyPassword(p0),
                              )),
                          SizedBox(height: 24 * sizeUnit),
                          Obx(() => iaBottomButton(
                                text: '확인',
                                isOk: controller.isOk.value,
                                onTap: () => controller.setPassword(id),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                '생생하게 꿈꾸면 반드시 이루어집니다.',
                style: STextStyle.subTitle4().copyWith(color: iaColorDarkGrey),
              ),
              SizedBox(height: 50 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_assets.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/global_widgets/custom_text_field.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/login/controller/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      onWillPop: GlobalFunction.isEnd,
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
                          SvgPicture.asset(GlobalAssets.svgLogoHorizontal, height: 24 * sizeUnit),
                          SizedBox(height: 24 * sizeUnit),
                          CustomTextField(
                            controller: controller.idController,
                            hintText: '아이디',
                          ),
                          SizedBox(height: 8 * sizeUnit),
                          CustomTextField(
                            controller: controller.passwordController,
                            hintText: '비밀번호',
                            obscureText: true,
                          ),
                          SizedBox(height: 24 * sizeUnit),
                          iaBottomButton(
                            text: '로그인하기',
                            onTap: () {
                              GlobalFunction.unFocus(context);
                              controller.loginFunc();
                            },
                          ),
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

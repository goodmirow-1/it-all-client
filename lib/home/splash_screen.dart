import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';
import '../../config/global_assets.dart';
import '../../config/global_widgets/base_widget.dart';
import '../../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String route = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  initState() {
    super.initState();

    animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationController.forward();

    Future.delayed(const Duration(milliseconds: 2000), () async {
      final prefs = await SharedPreferences.getInstance();
      final String id = prefs.getString('id') ?? '';
      final String password = prefs.getString('password') ?? '';

      if (id.isNotEmpty && password.isNotEmpty) {
        // 자동 로그인
        GlobalFunction.globalLogin(
          id: id,
          password: password,
          nullCallback: () {
            prefs.remove('id');
            prefs.remove('password');
            Get.off(() => LoginPage());
          },
        );
      } else {
        Get.off(() => LoginPage());
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        backgroundColor: iaColorRed,
        body: Center(
          child: Column(
            children: [
              Expanded(child: AnimatedLogo(animation: animation)),
              Text(
                '인류에 공헌하는 에듀테크 교육혁명',
                style: STextStyle.subTitle4().copyWith(color: Colors.white.withOpacity(0.6)),
              ),
              SizedBox(height: 50 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedLogo extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);

  const AnimatedLogo({Key? key, required Animation<double> animation}) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: SvgPicture.asset(
        GlobalAssets.svgLogoVertical,
        width: 96 * sizeUnit,
        color: Colors.white,
      ),
    );
  }
}

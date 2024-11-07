import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/board/board_page.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_assets.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/dashboard/dashboard_page.dart';
import 'package:itall_app/home/controller/main_page_controller.dart';
import 'package:itall_app/study/study_page.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  final MainPageController controller = Get.put(MainPageController());

  final List<Widget> widgetOptions = [
    DashboardPage(),
    // MealPage(),
    StudyPage(),
    BoardPage(),
  ];

  final List<Map<String, dynamic>> navItemList = [
    {'title': 'HOME', 'iconPath': GlobalAssets.svgHome},
    {'title': 'STUDY', 'iconPath': GlobalAssets.svgStudy},
    {'title': 'BOARD', 'iconPath': GlobalAssets.svgBell},
  ];

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      onWillPop: controller.onWillPop,
      child: GetBuilder<MainPageController>(
        builder: (_) {
          return Scaffold(
            body: widgetOptions[controller.currentIndex],
            bottomNavigationBar: bottomNavigationBar(),
          );
        }
      ),
    );
  }

  Widget bottomNavigationBar() {
    return Container(
      height: 56 * sizeUnit,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(18, 18, 18, 0.125),
            offset: Offset(0, -2),
            blurRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: iaColorRed,
        unselectedItemColor: iaColorBlack,
        onTap: (index) => controller.changePage(index),
        selectedLabelStyle: STextStyle.subTitle5().copyWith(color: iaColorRed),
        unselectedLabelStyle: STextStyle.subTitle5(),
        elevation: 0,
        items: List.generate(
          navItemList.length,
          (index) {
            final Map<String, dynamic> navItem = navItemList[index];

            return BottomNavigationBarItem(
              label: navItem['title'],
              icon: SvgPicture.asset(navItem['iconPath'], width: 24 * sizeUnit),
              activeIcon: SvgPicture.asset(navItem['iconPath'], width: 24 * sizeUnit, color: iaColorRed),
            );
          },
        ),
      ),
    );
  }
}

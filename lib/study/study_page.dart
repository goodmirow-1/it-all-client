import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/animated_tap_bar.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/get_extended_image.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/study/controller/study_chart_controller.dart';
import 'package:itall_app/study/controller/study_page_controller.dart';
import 'package:itall_app/study/study_chart_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../data/model/pure_study_ranking.dart';
import '../data/model/student.dart';
import '../profile/profile_page.dart';
import 'study_time_history_page.dart';

class StudyPage extends StatelessWidget {
  StudyPage({Key? key}) : super(key: key);

  final StudyChartController chartController = Get.put(StudyChartController());
  final StudyPageController controller = Get.put(StudyPageController());
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: appBar(context),
        body: GetBuilder<StudyPageController>(
            initState: (state) => controller.initState(),
            builder: (context) {
              if (controller.loading) return const Center(child: CircularProgressIndicator(color: iaColorRed));

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * sizeUnit),
                    profile(), // 프로필
                    SizedBox(height: 16 * sizeUnit),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedTapBar(
                            barIndex: controller.barIndex,
                            listTabItemTitle: controller.listTabItemTitle,
                            listTabItemWidth: controller.listTabItemWidth,
                            onPageChanged: (index) => controller.pageController.animateToPage(index, duration: AnimatedTapBar.duration, curve: AnimatedTapBar.curve),
                          ),
                        ),
                        switchWidget(), // 지난달, 이번달
                      ],
                    ),
                    SizedBox(
                      height: 302 * sizeUnit,
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: controller.listTabItemTitle.length,
                        onPageChanged: (value) => controller.changePage(value),
                        itemBuilder: (context, index) => ranking(),
                      ),
                    ),
                    SizedBox(height: 16 * sizeUnit),
                    Row(
                      children: [
                        SizedBox(width: 16 * sizeUnit),
                        Text('나의 순공 이력', style: STextStyle.headline3()),
                        const Spacer(),
                        periodSelectWidget(), // 일, 주, 월
                      ],
                    ),
                    SizedBox(height: 12 * sizeUnit),
                    StudyChartWidget(
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                    ),
                    SizedBox(height: 16 * sizeUnit),
                  ],
                ),
              );
            }),
      ),
    );
  }

  // 랭킹
  Widget ranking() {
    if (controller.rankingLoading) return const Center(child: CircularProgressIndicator(color: iaColorRed));

    Container rankingItem({required PureStudyRanking pureStudyRanking}) {
      return Container(
        width: double.infinity,
        height: 66 * sizeUnit,
        margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        padding: EdgeInsets.only(left: 16 * sizeUnit, right: 24 * sizeUnit),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          boxShadow: const [defaultBoxShadow],
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              pureStudyRanking.ranking == 1
                  ? GlobalAssets.svgGoldBadge
                  : pureStudyRanking.ranking == 2
                      ? GlobalAssets.svgSilverBadge
                      : GlobalAssets.svgBronzeBadge,
              width: 24 * sizeUnit,
            ),
            SizedBox(width: 16 * sizeUnit),
            ClipRRect(
              borderRadius: BorderRadius.circular(20 * sizeUnit),
              child: pureStudyRanking.student.imageURL == null
                  ? Container(
                      height: 40 * sizeUnit,
                      width: 40 * sizeUnit,
                      color: iaColorGrey,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                          pureStudyRanking.student.gender == null
                              ? GlobalAssets.svgDefaultImage
                              : pureStudyRanking.student.gender == Student.genderMan
                                  ? GlobalAssets.svgDefaultImageMan
                                  : GlobalAssets.svgDefaultImageWoman,
                          width: 40 * sizeUnit),
                    )
                  : GetExtendedImage(
                      url: pureStudyRanking.student.imageURL!,
                      width: 40 * sizeUnit,
                      height: 40 * sizeUnit,
                    ),
            ),
            SizedBox(width: 12 * sizeUnit),
            Text(pureStudyRanking.student.name, style: STextStyle.subTitle3()),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('누적 순공시간', style: STextStyle.subTitle4()),
                SizedBox(height: 4 * sizeUnit),
                Text('${pureStudyRanking.student.studyTime ~/ 60}시간 ${pureStudyRanking.student.studyTime % 60}분', style: STextStyle.headline3().copyWith(color: iaColorRed)),
              ],
            ),
          ],
        ),
      );
    }

    return controller.rankingList!.isEmpty
        ? Center(child: Text('데이터가 없습니다.', style: STextStyle.subTitle3().copyWith(color: iaColorDarkGrey)))
        : Column(
            children: [
              SizedBox(height: 16 * sizeUnit),
              Container(
                width: double.infinity,
                height: 48 * sizeUnit,
                margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                padding: EdgeInsets.only(left: 16 * sizeUnit, right: 24 * sizeUnit),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8 * sizeUnit),
                  boxShadow: const [defaultBoxShadow],
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('나의 랭킹', style: STextStyle.subTitle3())),
                    Row(
                      children: [
                        Text(controller.isNational ? '전국' : '센터', style: STextStyle.subTitle3()),
                        SizedBox(width: 8 * sizeUnit),
                        Text(
                          controller.rankingList!.last.student.id == nullInt ? '0등' : '${controller.rankingList!.last.ranking}등',
                          style: STextStyle.headline3().copyWith(color: iaColorRed),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16 * sizeUnit),
              Expanded(
                child: Column(
                  children: List.generate(controller.rankingList!.length - 1, (index) {
                    final PureStudyRanking pureStudyRanking = controller.rankingList![index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: index == 2 ? 0 : 8 * sizeUnit),
                      child: rankingItem(pureStudyRanking: pureStudyRanking),
                    );
                  }),
                ),
              ),
            ],
          );
  }

  // 프로필
  Container profile() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * sizeUnit),
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [defaultBoxShadow],
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Column(
        children: [
          userProfileWidget(student: GlobalData.loginUser),
          SizedBox(height: 16 * sizeUnit),
          Row(
            children: [
              Expanded(
                child: studyTimeBox(
                  title: '지난달\n누적 순공시간',
                  time: '${controller.lastMonthStudyTime! ~/ 60}시간 ${controller.lastMonthStudyTime! % 60}분',
                  onTap: () => Get.to(() => StudyTimeHistoryPage(isThisMonth: false)),
                ),
              ),
              SizedBox(width: 8 * sizeUnit),
              Expanded(
                child: studyTimeBox(
                  title: '이번달\n누적 순공시간',
                  time: '${controller.thisMonthStudyTime! ~/ 60}시간 ${controller.thisMonthStudyTime! % 60}분',
                  onTap: () => Get.to(() => StudyTimeHistoryPage(isThisMonth: true)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 순공시간 박스
  Widget studyTimeBox({required String title, required String time, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8 * sizeUnit),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: STextStyle.body3().copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4 * sizeUnit),
            Text(time, style: STextStyle.headline3().copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // 일, 주, 월
  Widget periodSelectWidget() {
    late final double leftPadding;

    switch (chartController.periodIndex) {
      case StudyChartController.periodDay:
        leftPadding = 3 * sizeUnit;
        break;
      case StudyChartController.periodWeek:
        leftPadding = 26 * sizeUnit;
        break;
      case StudyChartController.periodMonth:
        leftPadding = 50 * sizeUnit;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(right: 16 * sizeUnit),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * sizeUnit),
              boxShadow: const [defaultBoxShadow],
              color: Colors.white,
            ),
            width: 70 * sizeUnit,
            height: 24 * sizeUnit,
          ),
          AnimatedPositioned(
            left: leftPadding,
            top: 3 * sizeUnit,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 18 * sizeUnit,
              height: 18 * sizeUnit,
              decoration: const BoxDecoration(color: iaColorRed, shape: BoxShape.circle),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * sizeUnit),
            ),
            width: 70 * sizeUnit,
            height: 24 * sizeUnit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    chartController.changePeriod(StudyChartController.periodDay, itemScrollController: itemScrollController);
                    controller.update();
                  },
                  child: Text(
                    '일',
                    style: STextStyle.subTitle4().copyWith(
                      color: chartController.periodIndex == StudyChartController.periodDay ? Colors.white : iaColorDarkGrey,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    chartController.changePeriod(StudyChartController.periodWeek, itemScrollController: itemScrollController);
                    controller.update();
                  },
                  child: Text(
                    '주',
                    style: STextStyle.subTitle4().copyWith(
                      color: chartController.periodIndex == StudyChartController.periodWeek ? Colors.white : iaColorDarkGrey,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    chartController.changePeriod(StudyChartController.periodMonth, itemScrollController: itemScrollController);
                    controller.update();
                  },
                  child: Text(
                    '월',
                    style: STextStyle.subTitle4().copyWith(
                      color: chartController.periodIndex == StudyChartController.periodMonth ? Colors.white : iaColorDarkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 지난달, 이번달
  Widget switchWidget() {
    return Padding(
      padding: EdgeInsets.only(right: 16 * sizeUnit),
      child: InkWell(
        onTap: controller.periodSwitch,
        borderRadius: BorderRadius.circular(12 * sizeUnit),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * sizeUnit),
                boxShadow: const [defaultBoxShadow],
                color: Colors.white,
              ),
              width: 92 * sizeUnit,
              height: 24 * sizeUnit,
            ),
            AnimatedPositioned(
              left: controller.isThisMonth ? 46 * sizeUnit : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 46 * sizeUnit,
                height: 24 * sizeUnit,
                decoration: BoxDecoration(
                  color: iaColorRed,
                  borderRadius: BorderRadius.circular(18 * sizeUnit),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * sizeUnit),
              ),
              width: 92 * sizeUnit,
              height: 24 * sizeUnit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('지난달', style: STextStyle.subTitle4().copyWith(color: controller.isThisMonth ? iaColorDarkGrey : Colors.white)),
                  Text('이번달', style: STextStyle.subTitle4().copyWith(color: controller.isThisMonth ? Colors.white : iaColorDarkGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: '학습',
      centerTitle: true,
      leading: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: GestureDetector(
            onTap: () => Get.to(() => ProfilePage()),
            child: SvgPicture.asset(
              GlobalAssets.svgPersonInCircle,
              width: 24 * sizeUnit,
            ),
          ),
        ),
      ],
    );
  }
}

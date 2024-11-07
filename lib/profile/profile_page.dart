import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_assets.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/data/model/student.dart';
import 'package:itall_app/profile/controller/profile_page_controller.dart';
import 'package:itall_app/profile/d_day_setting_page.dart';
import 'package:itall_app/profile/history_view_page.dart';

import '../config/global_function.dart';
import '../config/global_widgets/get_extended_image.dart';
import '../data/global_data.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final ProfilePageController controller = Get.put(ProfilePageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: GetBuilder<ProfilePageController>(
        initState: (state) => controller.initState(),
        builder: (_) {
          if (controller.loading) return const Center(child: CircularProgressIndicator(color: iaColorRed));

          return Scaffold(
            appBar: appBar(context),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * sizeUnit),
                    profileWidget(context), // 프로필
                    SizedBox(height: 24 * sizeUnit),
                    if (!GlobalData.isParents) ...[
                      dDayBox(context), // d-day
                      SizedBox(height: 24 * sizeUnit),
                    ],
                    Text('나의 목표', style: STextStyle.headline3()),
                    SizedBox(height: 16 * sizeUnit),
                    goalBox(), // 목표
                    SizedBox(height: 24 * sizeUnit),
                    buildTitle(
                      title: '상벌점',
                      onTap: () => Get.to(() => HistoryViewPage(type: HistoryViewPage.reward)),
                    ),
                    SizedBox(height: 16 * sizeUnit),
                    defaultViewBox(label: '누적 상벌점', count: GlobalData.loginUser.totalRewardPoint),
                    SizedBox(height: 24 * sizeUnit),
                    buildTitle(
                      title: '공용공간 사용',
                      onTap: () => Get.to(() => HistoryViewPage(type: HistoryViewPage.commonSpace)),
                    ),
                    SizedBox(height: 16 * sizeUnit),
                    defaultViewBox(label: '이번달 사용 횟수', count: controller.publicSpaceUseCount),
                    SizedBox(height: 24 * sizeUnit),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Container defaultViewBox({required String label, required int count}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 8 * sizeUnit),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [defaultBoxShadow],
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: STextStyle.subTitle4()),
          SizedBox(height: 4 * sizeUnit),
          Text('$count', style: STextStyle.headline4().copyWith(color: iaColorRed)),
        ],
      ),
    );
  }

  Row buildTitle({required String title, required GestureTapCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: STextStyle.headline3()),
        GestureDetector(
          onTap: onTap,
          child: Text(
            '이력 보기',
            style: STextStyle.subTitle3().copyWith(color: iaColorRed),
          ),
        ),
      ],
    );
  }

  // 목표
  Container goalBox() {
    // 목표 아이템
    Row goalItem({required String svgPath, required String label, required String title, String? subTitle}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 24 * sizeUnit,
          ),
          SizedBox(width: 16 * sizeUnit),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: STextStyle.subTitle4()),
              SizedBox(height: 4 * sizeUnit),
              Text(title, style: STextStyle.headline4()),
              if (subTitle != null) ...[
                SizedBox(height: 4 * sizeUnit),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Get.width - 104 * sizeUnit),
                  child: Text(
                    subTitle,
                    style: STextStyle.subTitle4().copyWith(color: iaColorDarkGrey),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(16 * sizeUnit),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * sizeUnit),
        boxShadow: const [defaultBoxShadow],
      ),
      child: Column(
        children: [
          goalItem(
            svgPath: GlobalAssets.svgBachelorCap,
            label: '목표',
            title: GlobalData.loginUser.target,
          ),
          SizedBox(height: 16 * sizeUnit),
          goalItem(
            svgPath: GlobalAssets.svgDocument,
            label: '준비시험',
            title: GlobalData.loginUser.classifyClass == Student.classifyClassAdult ? '성인' : '${Student.classifyClassToText(GlobalData.loginUser.classifyClass)} | ${GlobalData.loginUser.examType}',
            subTitle: GlobalData.loginUser.examDetail,
          ),
        ],
      ),
    );
  }

  // d-day
  Container dDayBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 12 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit),
      width: double.infinity,
      decoration: BoxDecoration(
        color: iaColorBlack,
        borderRadius: BorderRadius.circular(8 * sizeUnit),
        boxShadow: const [defaultBoxShadow],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 24 * sizeUnit),
              Obx(() {
                final DateTime now = DateTime.now();
                final int dDay = GlobalData.dDay.isEmpty ? 0 : DateTime.parse(GlobalData.dDay.value).difference(DateTime(now.year, now.month, now.day)).inDays;

                return Text(
                  GlobalData.dDay.value.isEmpty ? 'D-DAY' : 'D-${dDay == 0 ? 'DAY' : dDay}',
                  style: STextStyle.headline3().copyWith(color: Colors.white),
                );
              }),
              GestureDetector(
                onTap: () {
                  Get.to(() => DDaySettingPage());
                },
                child: SvgPicture.asset(
                  GlobalAssets.svgPencil,
                  width: 24 * sizeUnit,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => Text(
                GlobalData.dDay.isEmpty ? '기간을 설정해주세요.' : '~ ${GlobalData.dDay.value}',
                style: STextStyle.body3().copyWith(color: Colors.white),
              )),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => Text(
                GlobalData.dDayText.isEmpty ? '문구를 입력해주세요.' : GlobalData.dDayText.value,
                style: STextStyle.headline5().copyWith(color: Colors.white),
              )),
        ],
      ),
    );
  }

  // 프로필 위젯
  Row profileWidget(BuildContext context) {
    // 학부모인 경우
    if (GlobalData.isParents) return userProfileWidget(student: GlobalData.loginUser);
    bool isAttendance = Student.isTodayAttendance(GlobalData.loginUser.attendances); // 오늘 등원했는지

    return Row(
      children: [
        GestureDetector(
          onTap: () => showBottomSheet(context),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(36 * sizeUnit),
                child: GlobalData.loginUser.imageURL == null
                    ? Container(
                        height: 72 * sizeUnit,
                        width: 72 * sizeUnit,
                        color: iaColorGrey,
                        child: Center(child: SvgPicture.asset(GlobalAssets.svgPlus, width: 24 * sizeUnit)),
                      )
                    : GetExtendedImage(
                        url: GlobalData.loginUser.imageURL!,
                        width: 72 * sizeUnit,
                        height: 72 * sizeUnit,
                      ),
              ),
              if (GlobalData.loginUser.imageURL != null) ...[
                Positioned(
                  bottom: 2 * sizeUnit,
                  right: 4 * sizeUnit,
                  child: SvgPicture.asset(GlobalAssets.svgSetting, width: 20 * sizeUnit),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 16 * sizeUnit),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(GlobalData.loginUser.name, style: STextStyle.subTitle1()),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit, vertical: 2 * sizeUnit),
                    decoration: BoxDecoration(
                      color: iaColorBlack,
                      borderRadius: BorderRadius.circular(20 * sizeUnit),
                    ),
                    child: Text(
                      isAttendance ? Student.stateToText(GlobalData.loginUser.state) : '미등원',
                      style: STextStyle.subTitle4().copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Text(GlobalData.loginUser.centerName, style: STextStyle.subTitle3()),
              SizedBox(height: 4 * sizeUnit),
              Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 113 * sizeUnit),
                    child: Text('학번: ${GlobalData.loginUser.number}', style: STextStyle.subTitle3()),
                  ),
                  SizedBox(width: 24 * sizeUnit),
                  Text('좌석: ${GlobalData.loginUser.seatNumber ?? '미정'}', style: STextStyle.subTitle3()),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Text('교실명: ${GlobalData.loginUser.className}', style: STextStyle.subTitle3()),
            ],
          ),
        ),
      ],
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * sizeUnit),
          topRight: Radius.circular(20 * sizeUnit),
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8 * sizeUnit),
            bottomSheetItem(
              text: '사진 선택',
              onTap: () {
                Get.back();
                controller.getImageEvent(isCamera: false);
              },
            ),
            bottomSheetItem(
              text: '사진 찍기',
              onTap: () {
                Get.back();
                controller.getImageEvent(isCamera: true);
              },
            ),
          ],
        );
      },
    );
  }

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: '내 정보',
      actions: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: 16 * sizeUnit),
            child: GestureDetector(
              onTap: () {
                showCustomDialog(
                  description: '로그아웃 하시겠어요?',
                  showCancelButton: true,
                  okFunc: () => GlobalFunction.globalLogout(),
                );
              },
              child: SvgPicture.asset(
                GlobalAssets.svgLogout,
                width: 24 * sizeUnit,
              ),
            ),
          ),
        )
      ],
    );
  }
}

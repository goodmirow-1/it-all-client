import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_assets.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/dashboard/controller/dashboard_controller.dart';
import 'package:itall_app/dashboard/exception_history_page.dart';
import 'package:itall_app/dashboard/exception_request_page.dart';
import 'package:itall_app/dashboard/qr_page.dart';
import 'package:itall_app/dashboard/exception_check_page.dart';
import 'package:itall_app/dashboard/attendance_widget.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/profile/profile_page.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({Key? key}) : super(key: key);

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: dashboardAppBar(context),
        body: GetBuilder<DashboardController>(
            initState: (_) => controller.initState(),
            builder: (_) {
              return SingleChildScrollView(
                controller: controller.dashboardScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * sizeUnit),
                    profile(), // 프로필
                    if (!GlobalData.isParents) ...[
                      SizedBox(height: 16 * sizeUnit),
                      currentStudents(), // 현재 공부 중인 학생
                    ],
                    SizedBox(height: 24 * sizeUnit),
                    AttendanceWidget(), // 출결 위젯
                  ],
                ),
              );
            }),
      ),
    );
  }

  // 현재 공부 중인 학생
  Container currentStudents() {
    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      padding: EdgeInsets.only(left: 16 * sizeUnit, right: 24 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [defaultBoxShadow],
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('현재 공부 중인 학생', style: STextStyle.subTitle3()),
          Text('${GlobalData.studyingCount}명', style: STextStyle.headline3().copyWith(color: iaColorRed)),
        ],
      ),
    );
  }

  // 프로필
  Container profile() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [defaultBoxShadow],
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Column(
        children: [
          if (!GlobalData.isParents) ...[
            Obx(() {
              final DateTime now = DateTime.now();
              final int dDay = GlobalData.dDay.isEmpty ? 0 : DateTime.parse(GlobalData.dDay.value).difference(DateTime(now.year, now.month, now.day)).inDays;
              final bool isNullDDay = GlobalData.dDay.isEmpty && GlobalData.dDayText.isEmpty; // dDay 설정되어 있는지 여부

              return Container(
                width: double.infinity,
                height: 48 * sizeUnit,
                decoration: BoxDecoration(
                  color: iaColorBlack,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8 * sizeUnit)),
                ),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    // dDay 설정 안되어 있다면 눌렀을 때 프로필 페이지로
                    if (isNullDDay) {
                      Get.to(() => ProfilePage());
                    }
                  },
                  child: Text(
                    isNullDDay ? 'D-DAY를 설정해주세요.' : '${GlobalData.dDayText.value}${GlobalData.dDay.isEmpty ? '' : ' D-${dDay == 0 ? 'DAY' : dDay}'}',
                    style: STextStyle.headline5().copyWith(color: isNullDDay ? iaColorDarkGrey : Colors.white),
                  ),
                ),
              );
            }),
          ],
          Padding(
            padding: EdgeInsets.all(16 * sizeUnit),
            child: Column(
              children: [
                userProfileWidget(student: GlobalData.loginUser),
                SizedBox(height: 16 * sizeUnit),
                if (GlobalData.isParents) ...[
                  iaDefaultButton(
                    text: '사유확인${GlobalData.exceptionCheckCount == 0 ? '' : '(${GlobalData.exceptionCheckCount})'}',
                    onTap: () => Get.to(() => ExceptionCheckPage()),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => iaDefaultButton(
                              text: controller.attendanceQRStatus.value == DashboardController.qrStatusAttendance ? '등원' : '하원',
                              onTap: () => Get.to(() => QrPage(qrType: QrPage.qrTypeAttendance))!.then((value) => controller.resetAttendances()), // QR 페이지 나오면 출석 데이터 재요청,
                            )),
                      ),
                      SizedBox(width: 6 * sizeUnit),
                      Expanded(
                        child: Obx(() => iaDefaultButton(
                              text: controller.outingQRStatus.value == DashboardController.qrStatusOuting ? '외출' : '복귀',
                              isOk: controller.attendanceQRStatus.value == DashboardController.qrStatusLeave,
                              onTap: () {
                                // 등원하기 전이면 외출 코드 못찍게
                                if (controller.attendanceQRStatus.value == DashboardController.qrStatusAttendance) {
                                  GlobalFunction.showToast(msg: '등원 후 시도해 주세요.');
                                } else {
                                  Get.to(() => QrPage(qrType: QrPage.qrTypeOuting))!.then((value) => controller.resetAttendances()); // QR 페이지 나오면 출석 데이터 재요청
                                }
                              },
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * sizeUnit),
                  Row(
                    children: [
                      Expanded(
                        child: iaDefaultButton(
                          text: '예외 신청',
                          isReverse: true,
                          onTap: () => Get.to(() => ExceptionRequestPage()),
                        ),
                      ),
                      SizedBox(width: 6 * sizeUnit),
                      Expanded(
                        child: iaDefaultButton(
                          text: '예외 신청 이력',
                          isReverse: true,
                          onTap: () => Get.to(() => ExceptionHistoryPage()),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize? dashboardAppBar(BuildContext context) {
    return customAppBar(
      context,
      titleWidget: SvgPicture.asset(GlobalAssets.svgLogoHorizontal, height: 24 * sizeUnit),
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

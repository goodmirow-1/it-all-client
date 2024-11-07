import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:intl/intl.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/wide_animated_tap_bar.dart';
import '../config/s_text_style.dart';
import '../data/model/absence.dart';
import 'controller/exception_check_page_controller.dart';

class ExceptionCheckPage extends StatelessWidget {
  ExceptionCheckPage({Key? key}) : super(key: key);

  final ExceptionCheckPageController controller = Get.put(ExceptionCheckPageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: '사유 확인'),
        body: GetBuilder<ExceptionCheckPageController>(
          initState: (state) => controller.initState(),
          builder: (_) {
            if(controller.loading) return const Center(child: CircularProgressIndicator(color: iaColorRed));

            return Column(
              children: [
                WideAnimatedTapBar(
                  barIndex: controller.barIndex,
                  listTabItemTitle: controller.listTabItemTitle,
                  listTabItemWidth: controller.listTabItemWidth,
                  bottomLineWidth: 41 * sizeUnit,
                  onPageChanged: (index) {
                    controller.pageController.animateToPage(index, duration: WideAnimatedTapBar.duration, curve: WideAnimatedTapBar.curve);
                  },
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.listTabItemTitle.length,
                    onPageChanged: (value) => controller.pageChange(value),
                    itemBuilder: (context, index) {
                      return ListView.builder(
                        itemCount: controller.isIndividual ? controller.absenceList.length : controller.regularAbsenceList.length,
                        itemBuilder: (context, index) => controller.isIndividual ? absenceItem(index: index) : regularAbsenceItem(index: index),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 개별 예외
  Widget absenceItem({required int index}) {
    final Absence absence = controller.absenceList[index];
    final DateTime now = DateTime.now();
    final bool timeOver = absence.periodStart.difference(now).inMinutes <= 0;

    Container reasonBox({required Absence absence, required bool timeOver}) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8 * sizeUnit),
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 12 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [defaultBoxShadow],
          borderRadius: BorderRadius.circular(8 * sizeUnit),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              absence.reason,
              style: STextStyle.body2().copyWith(height: 22 / 14),
            ),
            if (!timeOver && absence.acception == null) ...[
              SizedBox(height: 24 * sizeUnit),
              Row(
                children: [
                  Expanded(
                    child: iaDefaultButton(
                      text: '반려',
                      isReverse: true,
                      onTap: () => controller.modifyAccenption(exception: absence, acception: false),
                    ),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Expanded(
                    child: iaDefaultButton(
                      text: '수락',
                      onTap: () => controller.modifyAccenption(exception: absence, acception: true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56 * sizeUnit,
            margin: EdgeInsets.only(top: index == 0 ? 8 * sizeUnit : 0, bottom: 8 * sizeUnit),
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 6 * sizeUnit),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [defaultBoxShadow],
              borderRadius: BorderRadius.circular(8 * sizeUnit),
            ),
            child: Row(
              children: [
                Text(
                  (absence.acception == false || (timeOver && absence.acception != true)) ? '반려' : Absence.typeToText(absence.type),
                  style: STextStyle.subTitle3().copyWith(color: timeOver || absence.acception == false ? iaColorDarkGrey : iaColorRed),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (absence.type == Absence.typeOuting) ...[
                        Text(
                          DateFormat('yyyy.MM.dd\nHH시 mm분').format(absence.periodStart),
                          style: STextStyle.body2(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 16 * sizeUnit),
                        Text('~', style: STextStyle.body2()),
                        SizedBox(width: 16 * sizeUnit),
                        Text(
                          DateFormat('yyyy.MM.dd\nHH시 mm분').format(absence.periodEnd),
                          style: STextStyle.body2(),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          DateFormat('yyyy.MM.dd HH시 mm분').format(absence.periodStart),
                          style: STextStyle.body2(),
                        ),
                      ],
                    ],
                  ),
                ),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.reasonToggle(absence.id),
                    child: SvgPicture.asset(
                      controller.showReasonList.contains(absence.id) ? GlobalAssets.svgArrowTop : GlobalAssets.svgArrowBottom,
                      width: 24 * sizeUnit,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.showReasonList.contains(absence.id)
                ? reasonBox(
                    absence: absence,
                    timeOver: timeOver,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // 정기 예외
  Widget regularAbsenceItem({required int index}) {
    final AbsenceRegular regularAbsence = controller.regularAbsenceList[index];

    Container reasonBox({required AbsenceRegular absenceRegular, required bool timeOver}) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8 * sizeUnit),
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 12 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [defaultBoxShadow],
          borderRadius: BorderRadius.circular(8 * sizeUnit),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              absenceRegular.reason,
              style: STextStyle.body2().copyWith(height: 22 / 14),
            ),
            if (!timeOver) ...[
              if(absenceRegular.acception == null)...[
                SizedBox(height: 24 * sizeUnit),
                Row(
                  children: [
                    Expanded(
                      child: iaDefaultButton(
                        text: '반려',
                        isReverse: true,
                        onTap: () => controller.modifyAccenption(exception: absenceRegular, acception: false),
                      ),
                    ),
                    SizedBox(width: 8 * sizeUnit),
                    Expanded(
                      child: iaDefaultButton(
                        text: '수락',
                        onTap: () => controller.modifyAccenption(exception: absenceRegular, acception: true),
                      ),
                    ),
                  ],
                ),
              ] else if(absenceRegular.acception == true) ...[
                SizedBox(height: 24 * sizeUnit),
                iaDefaultButton(
                  text: '종료',
                  onTap: () => controller.modifyAccenption(exception: absenceRegular, acception: false, isEnd: true),
                ),
              ],
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56 * sizeUnit,
            margin: EdgeInsets.only(top: index == 0 ? 8 * sizeUnit : 0, bottom: 8 * sizeUnit),
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 6 * sizeUnit),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [defaultBoxShadow],
              borderRadius: BorderRadius.circular(8 * sizeUnit),
            ),
            child: Row(
              children: [
                Text(
                  regularAbsence.acception == false ? '종료' : '${AbsenceRegular.typeToText(regularAbsence.type)}${regularAbsence.acception == null ? '\n신청' : ''}',
                  style: STextStyle.subTitle3().copyWith(color: (regularAbsence.acception == false) ? iaColorDarkGrey : iaColorRed),
                ),
                Expanded(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: STextStyle.body2(),
                          children: [
                            const TextSpan(text: '매주 '),
                            TextSpan(text: regularAbsence.monday ? '월 ' : ''),
                            TextSpan(text: regularAbsence.tuesday ? '화 ' : ''),
                            TextSpan(text: regularAbsence.wednesday ? '수 ' : ''),
                            TextSpan(text: regularAbsence.thursday ? '목 ' : ''),
                            TextSpan(text: regularAbsence.friday ? '금 ' : ''),
                            TextSpan(text: regularAbsence.saturday ? '토 ' : ''),
                            TextSpan(text: regularAbsence.sunday ? '일 ' : ''),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${regularAbsence.periodStart.substring(0, 2)}시 ${regularAbsence.periodStart.substring(3, 5)}분',
                            style: STextStyle.body2(),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(width: 16 * sizeUnit),
                          Text('~', style: STextStyle.body2()),
                          SizedBox(width: 16 * sizeUnit),
                          Text(
                            '${regularAbsence.periodEnd.substring(0, 2)}시 ${regularAbsence.periodEnd.substring(3, 5)}분',
                            style: STextStyle.body2(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.reasonToggle(regularAbsence.id),
                    child: SvgPicture.asset(
                      controller.showReasonList.contains(regularAbsence.id) ? GlobalAssets.svgArrowTop : GlobalAssets.svgArrowBottom,
                      width: 24 * sizeUnit,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.showReasonList.contains(regularAbsence.id)
                ? reasonBox(
                    absenceRegular: regularAbsence,
                    timeOver: false,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

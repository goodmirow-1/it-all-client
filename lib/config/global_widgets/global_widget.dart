import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/data/model/attendance.dart';
import 'package:itall_app/data/model/student.dart';
import '../constants.dart';
import '../global_assets.dart';
import '../s_text_style.dart';
import 'get_extended_image.dart';

double sizeUnit = 1;

Widget defaultButton({required String text, required GestureTapCallback onTap, bool isOk = false, Color color = Colors.blue, GestureTapCallback? notOkFunc}) {
  return InkWell(
    onTap: () {
      if (isOk) {
        onTap();
      } else {
        if (notOkFunc != null) notOkFunc();
      }
    },
    child: Container(
      width: double.infinity,
      height: 40 * sizeUnit,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isOk ? color : Colors.grey,
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Text(
        text,
        style: STextStyle.subTitle3().copyWith(color: Colors.white),
      ),
    ),
  );
}

// 다이어로그
showCustomDialog({
  String description = '',
  String okText = '확인',
  bool showCancelButton = false,
  GestureTapCallback? okFunc,
  Color okColor = iaColorBlack,
}) {
  // 버튼
  Widget button({required String text, required GestureTapCallback onTap, Color bgColor = iaColorGrey}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28 * sizeUnit),
        child: Container(
          width: double.infinity,
          height: 48 * sizeUnit,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8 * sizeUnit),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: STextStyle.subTitle3().copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  return Get.dialog(
    Center(
      child: Container(
        width: 272 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6 * sizeUnit,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCancelButton) ...[
                SizedBox(height: 12 * sizeUnit),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12 * sizeUnit),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset(GlobalAssets.svgCancel, width: 24 * sizeUnit),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 24 * sizeUnit),
              ],
              if (description.isNotEmpty) ...[
                Text(
                  description,
                  style: STextStyle.subTitle3().copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 24 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                child: button(
                  text: okText,
                  bgColor: okColor,
                  onTap: okFunc ?? () => Get.back(),
                ),
              ),
              SizedBox(height: 16 * sizeUnit),
            ],
          ),
        ),
      ),
    ),
    barrierColor: const Color.fromRGBO(42, 46, 55, 0.3),
  );
}

// 위젯 다이어로그
showCustomWidgetDialog({
  String title = '',
  required Widget descriptionWidget,
  String okText = '확인',
  String cancelText = '취소',
  GestureTapCallback? okFunc,
  Color okColor = iaColorRed,
  bool isCancelButton = false,
  GestureTapCallback? cancelFunc,
}) {
  // 버튼
  Widget button({required String text, required GestureTapCallback onTap, Color bgColor = iaColorGrey, bool isSmallButton = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28 * sizeUnit),
        child: Container(
          width: isSmallButton ? 104 * sizeUnit : double.infinity,
          height: isSmallButton ? 48 * sizeUnit : 36 * sizeUnit,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28 * sizeUnit),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: STextStyle.subTitle1().copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  return Get.dialog(
    Center(
      child: Container(
        width: 280 * sizeUnit,
        padding: EdgeInsets.symmetric(vertical: 24 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6 * sizeUnit,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: STextStyle.subTitle1().copyWith(height: 24 / 16),
                  textAlign: TextAlign.center,
                ),
              ],
              descriptionWidget,
              SizedBox(height: 16 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
                child: isCancelButton
                    ? Row(
                        children: [
                          button(
                            text: cancelText,
                            isSmallButton: true,
                            onTap: cancelFunc ?? () => Get.back(),
                          ),
                          SizedBox(width: 8 * sizeUnit),
                          button(
                            text: okText,
                            bgColor: okColor,
                            isSmallButton: true,
                            onTap: okFunc ?? () => Get.back(),
                          ),
                        ],
                      )
                    : button(
                        text: okText,
                        bgColor: okColor,
                        onTap: okFunc ?? () => Get.back(),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierColor: const Color.fromRGBO(42, 46, 55, 0.3),
  );
}

// 앱바
PreferredSize? customAppBar(
  BuildContext context, {
  Widget? leading,
  String? title,
  List<Widget>? actions,
  Widget? titleWidget,
  PreferredSize? bottom,
  bool? centerTitle,
  double? leadingWidth,
  ScrollController? controller,
}) {
  Widget leadingWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 12 * sizeUnit),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => Get.back(),
          child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
        ),
      ),
    );
  }

  return PreferredSize(
    preferredSize: Size.fromHeight(bottom != null ? 90 * sizeUnit : 56 * sizeUnit),
    child: GestureDetector(
      onTap: () {
        if (Platform.isIOS && (controller != null && controller.positions.isNotEmpty)) {
          controller.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.bounceInOut);
        }
      },
      child: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 56 * sizeUnit,
        elevation: 0.0,
        centerTitle: centerTitle,
        titleSpacing: 0.0,
        leadingWidth: leadingWidth,
        iconTheme: const IconThemeData(color: iaColorBlack),
        leading: leading ?? (Get.currentRoute == '/MainPage' ? const SizedBox.shrink() : leadingWidget()),
        title: titleWidget ??
            (title != null
                ? Text(
                    title,
                    style: STextStyle.appBar().copyWith(color: iaColorBlack),
                  )
                : null),
        actions: actions,
        bottom: bottom,
      ),
    ),
  );
}

Widget iaDefaultButton({
  required String text,
  bool isOk = true,
  bool isReverse = false,
  required Function() onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(8 * sizeUnit),
    onTap: () {
      if (isOk) {
        onTap();
      }
    },
    child: Container(
      width: double.infinity,
      height: 40 * sizeUnit,
      decoration: BoxDecoration(
          color: isOk
              ? isReverse
                  ? Colors.white
                  : iaColorRed
              : iaColorGrey,
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          border: isReverse ? Border.all(color: iaColorRed) : null),
      child: Center(
        child: Text(text, style: STextStyle.button().copyWith(color: isReverse ? iaColorRed : Colors.white)),
      ),
    ),
  );
}

Widget iaBottomButton({
  required String text,
  bool isOk = true,
  required Function() onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(8 * sizeUnit),
    onTap: () {
      if (isOk) {
        onTap();
      }
    },
    child: Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8 * sizeUnit),
        color: iaColorRed,
      ),
      child: Center(
        child: Text(text, style: STextStyle.button().copyWith(color: Colors.white)),
      ),
    ),
  );
}

Widget bottomSheetCancelButton() {
  return InkWell(
    onTap: () => Get.back(),
    child: Padding(
      padding: EdgeInsets.all(16 * sizeUnit),
      child: Row(
        children: [
          SvgPicture.asset(GlobalAssets.svgCancel, width: 24 * sizeUnit),
          SizedBox(width: 8 * sizeUnit),
          Text('취소', style: STextStyle.body2()),
        ],
      ),
    ),
  );
}

// 바텀 시트 아이템
Widget bottomSheetItem({required String text, required GestureTapCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.all(16 * sizeUnit),
      child: Row(
        children: [
          Expanded(child: Text(text, style: STextStyle.body2())),
          SvgPicture.asset(GlobalAssets.svgArrowRight, width: 24 * sizeUnit),
        ],
      ),
    ),
  );
}

// 체크 박스
Widget iaCheckBox({String? label, required bool value, required GestureTapCallback onChanged, TextStyle? labelStyle}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onChanged,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          value ? GlobalAssets.svgCheckActive : GlobalAssets.svgCheckInactive,
          width: 24 * sizeUnit,
        ),
        if (label != null) ...[
          SizedBox(width: 4 * sizeUnit),
          Text(label, style: labelStyle ?? STextStyle.subTitle3()),
        ],
      ],
    ),
  );
}

Future<DateTime> dateTimePicker({required BuildContext context, DateTime? initialDateTime, DateTime? minimumDateTime}) async {
  late final DateTime date;
  late final DateTime time;

  date = await datePicker(context: context, initialDateTime: initialDateTime, minimumDateTime: minimumDateTime);
  time = await timePicker(context: context, initialDateTime: date, minimumDate: minimumDateTime);
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

Future<DateTime> datePicker({required BuildContext context, DateTime? initialDateTime, DateTime? minimumDateTime}) async {
  final DateTime now = DateTime.now();
  final DateTime initDateTime = initialDateTime ?? now;
  DateTime? date;

  await showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
            height: 200 * sizeUnit,
            child: CupertinoDatePicker(
              backgroundColor: Colors.white,
              initialDateTime: initDateTime,
              mode: CupertinoDatePickerMode.date,
              minimumDate: minimumDateTime ?? DateTime(now.year, now.month, now.day),
              minimumYear: now.year,
              onDateTimeChanged: (val) => date = val,
            ),
          ));

  date ??= initDateTime;
  return DateTime(date!.year, date!.month, date!.day, initDateTime.hour, initDateTime.minute);
}

// timePicker
Future<DateTime> timePicker({required BuildContext context, DateTime? initialDateTime, DateTime? minimumDate}) async {
  final DateTime now = DateTime.now();
  DateTime? time;

  await showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
            height: 200 * sizeUnit,
            child: CupertinoDatePicker(
              backgroundColor: Colors.white,
              initialDateTime: initialDateTime ?? now,
              mode: CupertinoDatePickerMode.time,
              minimumDate: minimumDate,
              onDateTimeChanged: (val) => time = val,
            ),
          ));

  time ??= initialDateTime ?? now;
  return time!;
}

// 프로필 위젯
Row userProfileWidget({required Student student}) {
  bool isAttendance = Student.isTodayAttendance(student.attendances); // 오늘 등원했는지

  return Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(36 * sizeUnit),
        child: student.imageURL == null
            ? Container(
                height: 72 * sizeUnit,
                width: 72 * sizeUnit,
                color: iaColorGrey,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  student.gender == null
                      ? GlobalAssets.svgDefaultImage
                      : student.gender == Student.genderMan
                          ? GlobalAssets.svgDefaultImageMan
                          : GlobalAssets.svgDefaultImageWoman,
                  width: 72 * sizeUnit,
                ),
              )
            : GetExtendedImage(
                url: student.imageURL!,
                width: 72 * sizeUnit,
                height: 72 * sizeUnit,
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
                  child: Text(student.name, style: STextStyle.subTitle1()),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit, vertical: 2 * sizeUnit),
                  decoration: BoxDecoration(
                    color: iaColorBlack,
                    borderRadius: BorderRadius.circular(20 * sizeUnit),
                  ),
                  child: Text(
                    isAttendance ? Student.stateToText(student.state) : '미등원',
                    style: STextStyle.subTitle4().copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * sizeUnit),
            Text(student.centerName, style: STextStyle.subTitle3()),
            SizedBox(height: 4 * sizeUnit),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 113 * sizeUnit),
                  child: Text('학번: ${student.number}', style: STextStyle.subTitle3()),
                ),
                SizedBox(width: 24 * sizeUnit),
                Text('좌석: ${student.seatNumber ?? '미정'}', style: STextStyle.subTitle3()),
              ],
            ),
            SizedBox(height: 4 * sizeUnit),
            Text('교실명: ${student.className}', style: STextStyle.subTitle3()),
          ],
        ),
      ),
    ],
  );
}

// 새로고침
Widget customRefreshIndicator({required Widget child, required Function() onRefresh}) {
  return CustomRefreshIndicator(
    onRefresh: () async {
      await onRefresh();
      return Future.delayed(const Duration(milliseconds: 500));
    },
    builder: (
      BuildContext context,
      Widget child,
      IndicatorController indicatorController,
    ) {
      return AnimatedBuilder(
        animation: indicatorController,
        builder: (BuildContext context, _) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              !indicatorController.isDragging && !indicatorController.isIdle
                  ? Positioned(
                      top: 12 * sizeUnit * indicatorController.value,
                      child: SizedBox(
                        width: 20 * sizeUnit,
                        height: 20 * sizeUnit,
                        child: CircularProgressIndicator(strokeWidth: 3 * sizeUnit, color: iaColorRed),
                      ),
                    )
                  : const SizedBox.shrink(),
              Transform.translate(
                offset: Offset(0, 40 * sizeUnit * indicatorController.value),
                child: Container(
                  color: Colors.white,
                  child: child,
                ),
              ),
            ],
          );
        },
      );
    },
    child: child,
  );
}

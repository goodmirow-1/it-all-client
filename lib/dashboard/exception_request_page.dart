import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/custom_text_field.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/dashboard/controller/exception_request_controller.dart';

import '../config/global_widgets/wide_animated_tap_bar.dart';
import '../data/model/absence.dart';

class ExceptionRequestPage extends StatelessWidget {
  ExceptionRequestPage({Key? key}) : super(key: key);

  final ExceptionRequestController controller = Get.put(ExceptionRequestController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExceptionRequestController>(
        initState: (state) => controller.initState(),
        builder: (_) {
          return BaseWidget(
            child: Scaffold(
              appBar: appBar(context),
              body: GestureDetector(
                onTap: () => GlobalFunction.unFocus(context),
                child: Column(
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
                      child: PageView(
                        controller: controller.pageController,
                        onPageChanged: (value) {
                          GlobalFunction.unFocus(context);
                          controller.pageChange(value);
                        },
                        children: [
                          individualRequest(context), // 개별
                          periodicRequest(context), // 정기
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // 정기
  Widget periodicRequest(BuildContext context) {
    // 시간 선택
    Container dateTimeBox() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15 * sizeUnit),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: iaColorBlack))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => timePicker(context: context, initialDateTime: controller.startDateTime.value).then((value) {
                controller.startDateTime(value);
                // 시작일시가 종료일시보다 크면 종료일시 시작일시로
                if (controller.startDateTime.value.difference(controller.endDateTime.value).inMinutes >= 0) controller.endDateTime(controller.startDateTime.value);
              }),
              child: Obx(() => Text(
                    DateFormat('HH시 mm분').format(controller.startDateTime.value),
                    style: STextStyle.body2(),
                  )),
            ),
            Text(
              '~',
              style: STextStyle.subTitle1().copyWith(fontWeight: FontWeight.w400),
            ),
            GestureDetector(
              onTap: () => timePicker(context: context, initialDateTime: controller.endDateTime.value, minimumDate: controller.startDateTime.value).then((value) => controller.endDateTime(value)),
              child: Obx(() => Text(
                    DateFormat('HH시 mm분').format(controller.endDateTime.value),
                    style: STextStyle.body2(),
                  )),
            ),
          ],
        ),
      );
    }

    // 요일 체크박스 리스트
    Obx dayCheckWrap() {
      return Obx(() => Wrap(
            runSpacing: 8 * sizeUnit,
            spacing: 22 * sizeUnit,
            children: List.generate(controller.dayOfWeekList.length, (index) {
              final String dayOfWeek = controller.dayOfWeekList[index];

              return iaCheckBox(
                label: dayOfWeek,
                value: controller.daysOfWeek.contains(dayOfWeek),
                onChanged: () => controller.dayOfWeekToggle(dayOfWeek),
              );
            }),
          ));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16 * sizeUnit),
            Text('예외', style: STextStyle.headline3()),
            SizedBox(height: 16 * sizeUnit),
            exceptionCheckList(), // 예외
            SizedBox(height: 24 * sizeUnit),
            Text('요일 선택', style: STextStyle.headline3()),
            SizedBox(height: 16 * sizeUnit),
            dayCheckWrap(), // 요일 체크박스
            SizedBox(height: 24 * sizeUnit),
            Obx(() => controller.exception.value == AbsenceRegular.typeAbsent
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('시간 선택', style: STextStyle.headline3()),
                      dateTimeBox(), // 시간 선택
                      SizedBox(height: 24 * sizeUnit),
                    ],
                  )),
            Text('사유 작성', style: STextStyle.headline3()),
            SizedBox(height: 12 * sizeUnit),
            customTextField(),
          ],
        ),
      ),
    );
  }

  // 개별
  Widget individualRequest(BuildContext context) {
    // 날짜
    Container dateTimeBox() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15 * sizeUnit),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: iaColorBlack))),
        alignment: Alignment.center,
        child: Obx(() {
          if (controller.exception.value == nullInt) {
            return const SizedBox.shrink();
          } else if (controller.exception.value == Absence.typeOuting) {
            // 외출
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => dateTimePicker(context: context, initialDateTime: controller.startDateTime.value).then((value) {
                    controller.startDateTime(value);

                    if (controller.vacationTicket.value == ExceptionRequestController.vacationTicketOuting) {
                      controller.endDateTimeAddAtStartTime(addDuration: const Duration(minutes: 90)); // 외출권 사용시 시작 시간에서 90분 더하기
                    } else if (controller.vacationTicket.value == ExceptionRequestController.vacationTicketHalfVacation) {
                      controller.endDateTimeAddAtStartTime(addDuration: const Duration(hours: 5)); // 반휴권 사용시 시작 시간에서 5시간 더하기
                    } else if (controller.startDateTime.value.difference(controller.endDateTime.value).inMinutes >= 0) {
                      controller.endDateTime(controller.startDateTime.value); // 시작일시가 종료일시보다 크면 종료일시 시작일시로
                    }
                  }),
                  child: Obx(() => Text(
                        DateFormat('yyyy.MM.dd.HH시 mm분').format(controller.startDateTime.value),
                        style: STextStyle.body2(),
                      )),
                ),
                Text(
                  '~',
                  style: STextStyle.subTitle1().copyWith(fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.vacationTicket.value != ExceptionRequestController.vacationTicketOuting && controller.vacationTicket.value != ExceptionRequestController.vacationTicketHalfVacation) {
                      dateTimePicker(context: context, initialDateTime: controller.endDateTime.value, minimumDateTime: controller.startDateTime.value).then((value) => controller.endDateTime(value));
                    }
                  },
                  child: Obx(() => Text(
                        DateFormat('yyyy.MM.dd.HH시 mm분').format(controller.endDateTime.value),
                        style: STextStyle.body2().copyWith(color: controller.vacationTicket.value == ExceptionRequestController.vacationTicketOuting || controller.vacationTicket.value == ExceptionRequestController.vacationTicketHalfVacation ? iaColorDarkGrey : iaColorBlack),
                      )),
                ),
              ],
            );
          } else if (controller.exception.value == Absence.typeAbsent) {
            // 결석
            return GestureDetector(
              onTap: () => datePicker(context: context, initialDateTime: controller.startDateTime.value).then((value) {
                controller.startDateTime(DateTime(value.year, value.month, value.day));
                controller.endDateTime(controller.startDateTime.value);
              }),
              child: Obx(() => Text(
                    DateFormat('yyyy.MM.dd').format(controller.startDateTime.value),
                    style: STextStyle.body2(),
                  )),
            );
          } else {
            // 조퇴, 지각
            return GestureDetector(
              onTap: () => dateTimePicker(context: context, initialDateTime: controller.startDateTime.value).then((value) {
                controller.startDateTime(value);
                controller.endDateTime(value);
              }),
              child: Obx(() => Text(
                    DateFormat('yyyy.MM.dd.HH시 mm분').format(controller.startDateTime.value),
                    style: STextStyle.body2(),
                  )),
            );
          }
        }),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16 * sizeUnit),
            Text('예외', style: STextStyle.headline3()),
            SizedBox(height: 16 * sizeUnit),
            exceptionCheckList(), // 예외 체크박스 리스트
            SizedBox(height: 24 * sizeUnit),
            Text('날짜', style: STextStyle.headline3()),
            dateTimeBox(), // 날짜
            SizedBox(height: 24 * sizeUnit),
            Row(
              children: [
                Expanded(child: Text('사유 작성', style: STextStyle.headline3())),
                Obx(
                  () => controller.exception.value == Absence.typeOuting
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.checkVacationTicket(ExceptionRequestController.vacationTicketOuting),
                          child: Row(
                            children: [
                              Text(
                                '외출권 사용',
                                style: STextStyle.subTitle3().copyWith(height: 1.2),
                              ),
                              SizedBox(width: 4 * sizeUnit),
                              Obx(() => iaCheckBox(
                                    value: controller.vacationTicket.value == ExceptionRequestController.vacationTicketOuting,
                                    onChanged: () => controller.checkVacationTicket(ExceptionRequestController.vacationTicketOuting),
                                  )),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(width: 16 * sizeUnit),
                Obx(
                  () => controller.exception.value == Absence.typeOuting
                      ? Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => controller.checkVacationTicket(ExceptionRequestController.vacationTicketHalfVacation),
                              child: Text(
                                '반휴권 사용',
                                style: STextStyle.subTitle3().copyWith(height: 1.2),
                              ),
                            ),
                            SizedBox(width: 4 * sizeUnit),
                            Obx(() => iaCheckBox(
                                  value: controller.vacationTicket.value == ExceptionRequestController.vacationTicketHalfVacation,
                                  onChanged: () => controller.checkVacationTicket(ExceptionRequestController.vacationTicketHalfVacation),
                                )),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                Obx(
                  () => controller.exception.value == Absence.typeAbsent
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.checkVacationTicket(ExceptionRequestController.vacationTicketVacation),
                          child: Row(
                            children: [
                              Text(
                                '휴가권 사용',
                                style: STextStyle.subTitle3().copyWith(height: 1.2),
                              ),
                              SizedBox(width: 4 * sizeUnit),
                              Obx(() => iaCheckBox(
                                    value: controller.vacationTicket.value == ExceptionRequestController.vacationTicketVacation,
                                    onChanged: () => controller.checkVacationTicket(ExceptionRequestController.vacationTicketVacation),
                                  )),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            SizedBox(height: 12 * sizeUnit),
            customTextField(),
          ],
        ),
      ),
    );
  }

  // 예외 체크박스 리스트
  Obx exceptionCheckList() {
    return Obx(() => Row(
          children: [
            iaCheckBox(
              label: '외출',
              value: controller.exception.value == (controller.isIndividual ? Absence.typeOuting : AbsenceRegular.typeOuting),
              onChanged: () => controller.exceptionChange(controller.isIndividual ? Absence.typeOuting : AbsenceRegular.typeOuting),
            ),
            if (controller.isIndividual) ...[
              SizedBox(width: 24 * sizeUnit),
              iaCheckBox(
                label: '조퇴',
                value: controller.exception.value == Absence.typeEarlyLeave,
                onChanged: () => controller.exceptionChange(Absence.typeEarlyLeave),
              ),
            ],
            SizedBox(width: 24 * sizeUnit),
            iaCheckBox(
              label: '결석',
              value: controller.exception.value == (controller.isIndividual ? Absence.typeAbsent : AbsenceRegular.typeAbsent),
              onChanged: () => controller.exceptionChange(controller.isIndividual ? Absence.typeAbsent : AbsenceRegular.typeAbsent),
            ),
            if (controller.isIndividual) ...[
              SizedBox(width: 24 * sizeUnit),
              iaCheckBox(
                label: '지각',
                value: controller.exception.value == Absence.typeLateness,
                onChanged: () => controller.exceptionChange(Absence.typeLateness),
              ),
            ],
          ],
        ));
  }

  CustomTextField customTextField() {
    return CustomTextField(
      controller: controller.textEditingController,
      minLines: 6,
      maxLines: 500,
      maxLength: 500,
      hintText: '사유를 작성해 주세요.',
      style: STextStyle.body2(),
      onChanged: (p0) => controller.reason(p0),
    );
  }

  PreferredSize? appBar(BuildContext context) {
    return customAppBar(
      context,
      title: controller.isIndividual ? '예외 신청' : '정기 신청',
      actions: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: 16 * sizeUnit),
            child: GestureDetector(
              onTap: () {
                if (controller.isOk.value) {
                  if (controller.isIndividual) {
                    controller.requestException(); // 예외 신청
                  } else {
                    controller.requestRegularException(); // 정기 신청
                  }
                }
              },
              child: Obx(() => Text(
                    '완료',
                    style: STextStyle.subTitle3().copyWith(
                      color: controller.isOk.value ? iaColorRed : iaColorDarkGrey,
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}

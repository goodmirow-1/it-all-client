import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_assets.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/custom_text_field.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/profile/controller/d_day_setting_controller.dart';

import '../config/s_text_style.dart';

class DDaySettingPage extends StatelessWidget {
  DDaySettingPage({Key? key}) : super(key: key);

  final DDaySettingController controller = Get.put(DDaySettingController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: appBar(context),
        body: GetBuilder<DDaySettingController>(
            initState: (state) => controller.initState(),
            builder: (_) {
              return GestureDetector(
                onTap: () => GlobalFunction.unFocus(context),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16 * sizeUnit),
                        Text('날짜', style: STextStyle.headline3()),
                        dateBox(context), // 날짜
                        SizedBox(height: 24 * sizeUnit),
                        Text('목표 작성', style: STextStyle.headline3()),
                        SizedBox(height: 16 * sizeUnit),
                        CustomTextField(
                          controller: controller.dDayTextController,
                          hintText: '문구를 입력해주세요.',
                          style: STextStyle.body2(),
                          hintStyle: STextStyle.body2().copyWith(color: iaColorDarkGrey),
                          maxLength: 20,
                          minLines: 6,
                          maxLines: 20,
                          onChanged: (p0) => controller.tmpDDayText(p0),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  // 날짜
  Container dateBox(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: iaColorBlack)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.dDayPicker(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Obx(() => Text(
                    controller.tmpDDay.isEmpty ? '0000-00-00' : controller.tmpDDay.value,
                    style: STextStyle.body2(),
                  )),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () => controller.tmpDDay(''),
                child: SvgPicture.asset(GlobalAssets.svgCancel, width: 24 * sizeUnit),
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
      title: '목표설정',
      actions: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: 16 * sizeUnit),
            child: GestureDetector(
              onTap: () => controller.setDDay(),
              child: Text(
                '완료',
                style: STextStyle.subTitle3().copyWith(
                  color: iaColorRed,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

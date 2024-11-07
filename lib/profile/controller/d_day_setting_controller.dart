import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/global_function.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/global_data.dart';

class DDaySettingController extends GetxController {
  static get to => Get.find<DDaySettingController>();

  final TextEditingController dDayTextController = TextEditingController();

  RxString tmpDDay = GlobalData.dDay.value.obs; // 임시 디데이
  RxString tmpDDayText = GlobalData.dDayText.value.obs; // 임시 디데이 문구

  void initState(){
    tmpDDay(GlobalData.dDay.value);
    tmpDDayText(GlobalData.dDayText.value);

    dDayTextController.text = GlobalData.dDayText.isEmpty ? '' : GlobalData.dDayText.value;
  }

  @override
  onClose(){
    super.onClose();

    dDayTextController.dispose();
  }

  // d-day datePicker
  Future<void> dDayPicker(BuildContext context) async{
    DateTime dateTime = await datePicker(context: context, initialDateTime: tmpDDay.isEmpty ? null : DateTime.parse(tmpDDay.value));
    final String dDay = dateTime.toString().substring(0, 10);
    tmpDDay(dDay);
  }

  // d-day 세팅
  Future<void> setDDay() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('dDay', tmpDDay.value);
    prefs.setString('dDayText', tmpDDayText.value);

    GlobalData.dDay(tmpDDay.value);
    GlobalData.dDayText(tmpDDayText.value);
    Get.back(); // 프로필 페이지로 이동
    GlobalFunction.showToast(msg: '목표설정이 완료되었습니다.');
  }
}
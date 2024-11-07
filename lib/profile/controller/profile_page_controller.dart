import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itall_app/dashboard/controller/dashboard_controller.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/home/controller/main_page_controller.dart';
import 'package:itall_app/repository/attendance_repository.dart';
import 'package:itall_app/repository/student_repository.dart';
import 'package:dio/dio.dart' as DIO;
import 'package:itall_app/study/controller/study_page_controller.dart';

import '../../config/global_function.dart';
import '../../data/model/attendance.dart';
import '../../data/model/student.dart';

class ProfilePageController extends GetxController {
  static get to => Get.find<ProfilePageController>();

  FocusNode dDayTextFocusNode = FocusNode();
  int publicSpaceUseCount = 0; // 이번달 공용공간 사용 횟수
  bool loading = true;

  void initState() async {
    // 학생 정보 최신화
    Student? student = await StudentRepository.selectDetail(userID: GlobalData.loginUser.id);
    if (student != null) {
      final String centerName = GlobalData.loginUser.centerName;
      final String className = GlobalData.loginUser.className;
      final List<Attendance> attendances = GlobalData.loginUser.attendances;
      GlobalData.loginUser = student;
      GlobalData.loginUser.centerName = centerName;
      GlobalData.loginUser.className = className;
      GlobalData.loginUser.attendances = attendances;
    }

    publicSpaceUseCount = await AttendanceRepository.selectPublicSpaceUseCount(userID: GlobalData.loginUser.id); // 이번달 공용공간 사용 횟수

    loading = false;
    update();
  }

  // 사진 가져오기
  Future<void> getImageEvent({required bool isCamera}) async {
    final ImagePicker picker = ImagePicker();
    XFile? selectedImage = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (selectedImage != null) {
      if (await GlobalFunction.isBigFile(selectedImage)) {
        return GlobalFunction.showToast(msg: '사진의 크기는 2mb를 넘을 수 없습니다.');
      } else {
        await modifyProfileImage(selectedImage); // 프로필 이미지 수정
        update();
      }
    }
  }

  // 프로필 이미지 수정
  Future<void> modifyProfileImage(XFile image) async {
    final String fileName = image.path.split('/').last;

    final DIO.FormData formData = DIO.FormData.fromMap({
      'userID': GlobalData.loginUser.id,
      'file': await DIO.MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    String? result = await StudentRepository.modifyProfileImage(formData: formData);

    if(result != null) {
      GlobalData.loginUser.imageURL = result;
      update(); // 프로필 페이지 업데이트

      final MainPageController mainPageController = Get.find<MainPageController>();
      if(mainPageController.currentIndex == 0) {
        DashboardController.to.update(); // 대시보드 업데이트
      } else if(mainPageController.currentIndex == 1) {
        StudyPageController.to.update(); // 스터디 페이지 업데이트
      }
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }
}

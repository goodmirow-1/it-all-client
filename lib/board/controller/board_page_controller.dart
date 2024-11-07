import 'package:get/get.dart';
import 'package:itall_app/data/model/notice.dart';
import 'package:itall_app/repository/board_repository.dart';

class BoardPageController extends GetxController {
  static get to => Get.find<BoardPageController>();

  List<Notice> noticeList = [];
  bool loading = true;

  Future<void> initState() async{
    if(!loading) {
      loading = true;
      update();
    }

    noticeList = await BoardRepository.selectList();

    loading = false;
    update();
  }

  // 새로고침
  Future<void> onRefresh() async{
    noticeList = await BoardRepository.selectList();
    update();
  }
}
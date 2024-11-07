import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/data/model/pure_study_ranking.dart';
import 'package:itall_app/repository/study_repository.dart';

class StudyPageController extends GetxController {
  static get to => Get.find<StudyPageController>();

  final PageController pageController = PageController();
  final List<String> listTabItemTitle = ['전국', '센터별'];
  final List<double> listTabItemWidth = [26 * sizeUnit, 39 * sizeUnit];

  List<PureStudyRanking>? thisMonthNationalRankingList; // 전국 순공시간 랭킹 (이번달)
  List<PureStudyRanking>? lastMonthNationalRankingList; // 전국 순공시간 랭킹 (지난달)
  List<PureStudyRanking>? thisMonthCenterRankingList; // 센터 순공시간 랭킹 (이번달)
  List<PureStudyRanking>? lastMonthCenterRankingList; // 센터 순공시간 랭킹 (지난달)

  // 화면에 보이지는 랭킹 리스트
  List<PureStudyRanking>? get rankingList => isNational
      ? isThisMonth
          ? thisMonthNationalRankingList
          : lastMonthNationalRankingList
      : isThisMonth
          ? thisMonthCenterRankingList
          : lastMonthCenterRankingList;

  int barIndex = 0;
  bool loading = true; // 전체 로딩
  bool rankingLoading = false; // 랭킹 로딩
  bool isThisMonth = true; // 이번달인지
  bool get isNational => barIndex == 0; // 전국 OR 센터
  int? thisMonthStudyTime; // 이번달 순공시간 (분)
  int? lastMonthStudyTime; // 지난달 순공시간 (분)

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  void initState() async {
    // 스크롤 세팅
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(pageController.hasClients) pageController.jumpToPage(barIndex);
    });

    await setRankingList(); // 랭킹 리스트 세팅

    // 이번달 누적 순공시간 처리
    if(thisMonthStudyTime == null) {
      if(thisMonthNationalRankingList != null && thisMonthNationalRankingList!.isNotEmpty) {
        thisMonthStudyTime = thisMonthNationalRankingList!.last.student.studyTime;
      }
    }

    // 지난달 누적 순공시간 처리
    lastMonthStudyTime ??= await StudyRepository.selectLastMonthTime(userID: GlobalData.loginUser.id);

    if(loading) {
      loading = false;
      update();
    }
  }

  // 랭킹 리스트 세팅 (리스트가 null 아닌 경우만)
  Future<void> setRankingList() async {
    if(rankingList != null) return;
    if(kDebugMode) print('set ranking list!');

    if(isNational) {
      // 전국인 경우
      if(isThisMonth) {
        // 이번달인 경우
        thisMonthNationalRankingList = await StudyRepository.selectRank(centerID: 0, isThisMonth: true, userID: GlobalData.loginUser.id);
      } else {
        // 저번달인 경우
        lastMonthNationalRankingList = await StudyRepository.selectRank(centerID: 0, isThisMonth: false, userID: GlobalData.loginUser.id);
      }
    } else {
      // 센터인 경우
      if(isThisMonth) {
        // 이번달인 경우
        thisMonthCenterRankingList = await StudyRepository.selectRank(centerID: GlobalData.loginUser.centerID, isThisMonth: true, userID: GlobalData.loginUser.id);
      } else {
        // 저번달인 경우
        lastMonthCenterRankingList = await StudyRepository.selectRank(centerID: GlobalData.loginUser.centerID, isThisMonth: false, userID: GlobalData.loginUser.id);
      }
    }
  }

  // 페이지 변경
  Future<void> changePage(int index) async{
    barIndex = index;

    if(rankingList == null) {
      rankingLoading = true;
      update();
      await setRankingList(); // 랭킹 리스트 세팅
    }

    rankingLoading = false;
    update();
  }

  // 주간, 월간 스위치
  Future<void> periodSwitch() async{
    isThisMonth = !isThisMonth;

    if(rankingList == null) {
      rankingLoading = true;
      update();
      await setRankingList(); // 랭킹 리스트 세팅
    }

    rankingLoading = false;
    update();
  }
}

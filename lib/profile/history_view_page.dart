import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/data/model/public_space_use.dart';
import 'package:itall_app/profile/controller/history_view_page_controller.dart';

import '../config/global_function.dart';
import '../data/model/reward.dart';

class HistoryViewPage extends StatelessWidget {
  HistoryViewPage({Key? key, required this.type}) : super(key: key);

  final int type;

  final HistoryViewPageController controller = Get.put(HistoryViewPageController());

  static const int reward = 0; // 상벌점
  static const int commonSpace = 1; // 공용공간 사용

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: GetBuilder<HistoryViewPageController>(
          initState: (state) => controller.initState(type),
          builder: (_) {
            if (controller.loading) return const Center(child: CircularProgressIndicator(color: iaColorRed));

            return Scaffold(
              appBar: customAppBar(context, title: controller.title),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.resultList.length,
                      itemBuilder: (context, index) {
                        final result = controller.resultList[index];

                        if (controller.isReward) {
                          return rewardItem(reward: result);
                        } else {
                          return publicSpaceUseItem(publicSpaceUse: result);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  // 상점 이력 아이템
  Container rewardItem({required Reward reward}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 24 * sizeUnit, 16 * sizeUnit),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: iaColorGrey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GlobalFunction.createdAtToDate(createdAt: reward.createdAt, pattern: 'yyyy.MM.dd HH시 mm분'),
                  style: STextStyle.subTitle4().copyWith(color: iaColorRed),
                ),
                SizedBox(height: 16 * sizeUnit),
                Text(
                  reward.reason,
                  style: STextStyle.subTitle3(),
                ),
              ],
            ),
          ),
          Text(
            '${reward.value}',
            style: STextStyle.subTitle1().copyWith(color: reward.value < 0 ? iaColorRed : iaColorBlack),
          ),
        ],
      ),
    );
  }

  // 공용공간 사용 이력 아이템
  Container publicSpaceUseItem({required PublicSpaceUse publicSpaceUse}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 24 * sizeUnit, 16 * sizeUnit),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: iaColorGrey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${GlobalFunction.createdAtToDate(createdAt: publicSpaceUse.createdAt)} (${publicSpaceUse.classNum}교시)',
            style: STextStyle.subTitle4().copyWith(color: iaColorRed),
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '공용공간 신청',
            style: STextStyle.subTitle3(),
          ),
        ],
      ),
    );
  }
}

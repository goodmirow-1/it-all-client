import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:itall_app/board/controller/board_page_controller.dart';
import 'package:itall_app/board/notice_detail_page.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import 'package:itall_app/config/s_text_style.dart';
import 'package:itall_app/data/global_data.dart';
import 'package:itall_app/data/model/notice.dart';

import '../config/global_assets.dart';
import '../profile/profile_page.dart';

class BoardPage extends StatelessWidget {
  BoardPage({Key? key}) : super(key: key);

  final BoardPageController controller = Get.put(BoardPageController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: appBar(context),
        body: GetBuilder<BoardPageController>(
            initState: (state) => controller.initState(),
            builder: (_) {
              if (controller.loading) return const Center(child: CircularProgressIndicator(color: iaColorRed));

              return customRefreshIndicator(
                onRefresh: controller.onRefresh,
                child: ListView.builder(
                  itemCount: controller.noticeList.length,
                  itemBuilder: (context, index) {
                    return noticeCard(index: index);
                  },
                ),
              );
            }),
      ),
    );
  }

  // 공지 카드
  Widget noticeCard({required int index}) {
    final Notice notice = controller.noticeList[index];

    return GestureDetector(
      onTap: () => Get.to(() => NoticeDetailPage(notice: notice)),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: index == 0 ? 16 * sizeUnit : 0, bottom: 16 * sizeUnit, right: 16 * sizeUnit, left: 16 * sizeUnit),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          color: Colors.white,
          boxShadow: const [defaultBoxShadow],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 48 * sizeUnit,
              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
              decoration: BoxDecoration(color: iaColorBlack, borderRadius: BorderRadius.vertical(top: Radius.circular(8 * sizeUnit))),
              alignment: Alignment.center,
              child: Text(
                notice.title,
                style: STextStyle.subTitle3().copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16 * sizeUnit),
                  Text(
                    notice.contents,
                    style: STextStyle.subTitle3(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16 * sizeUnit),
                  Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: const Color(0xFFEFEFEF)),
                  SizedBox(height: 8 * sizeUnit),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${GlobalData.loginUser.centerName} 외 ${(notice.targetCenter.split('/').length > 1) ? "${notice.targetCenter.split('/').length - 1}개" : ""}', style: STextStyle.subTitle4().copyWith(color: iaColorRed)),
                      Text(
                        GlobalFunction.createdAtToDate(createdAt: notice.showDay),
                        style: STextStyle.subTitle4().copyWith(color: iaColorRed),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * sizeUnit),
                ],
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
      title: '공지사항',
      leading: const SizedBox.shrink(),
      centerTitle: true,
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

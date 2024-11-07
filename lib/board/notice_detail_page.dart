import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itall_app/board/controller/notice_detail_controller.dart';
import 'package:itall_app/config/global_function.dart';
import 'package:itall_app/config/global_widgets/base_widget.dart';
import '../config/constants.dart';
import '../config/global_widgets/get_extended_image.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import '../data/model/notice.dart';

class NoticeDetailPage extends StatelessWidget {
  NoticeDetailPage({Key? key, required this.notice}) : super(key: key);

  final Notice notice;

  final NoticeDetailController controller = Get.put(NoticeDetailController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context),
        body: GetBuilder<NoticeDetailController>(
            initState: (state) => controller.initState(notice),
            builder: (_) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16 * sizeUnit),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${GlobalData.loginUser.centerName} 외 ${(notice.targetCenter.split('/').length > 1) ? "${notice.targetCenter.split('/').length - 1}개" : ""}', style: STextStyle.subTitle4().copyWith(color: iaColorRed)),
                          Text(GlobalFunction.createdAtToDate(createdAt: notice.showDay), style: STextStyle.subTitle4().copyWith(color: iaColorRed)),
                        ],
                      ),
                      SizedBox(height: 16 * sizeUnit),
                      Text(notice.title, style: STextStyle.headline3()),
                      if (controller.haveImage) ...[
                        SizedBox(height: 16 * sizeUnit),
                        buildImage(), // 이미지
                      ],
                      SizedBox(height: 16 * sizeUnit),
                      Text(
                        notice.contents,
                        style: STextStyle.subTitle3().copyWith(height: 22 / 14),
                      ),
                      SizedBox(height: 16 * sizeUnit),
                      Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: const Color(0xFFEFEFEF)),
                      if (controller.haveFile) ...[
                        SizedBox(height: 16 * sizeUnit),
                        buildFile(), // 파일
                      ],
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  // 이미지
  Widget buildImage() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: notice.fileList.length,
      itemBuilder: (context, index) {
        final NoticeFile image = notice.fileList[index];
        if (!image.isPhoto) return const SizedBox.shrink(); // 이미지 아닌 경우

        final double ratio = image.height / image.width;
        final double height = (Get.width - 32 * sizeUnit) * ratio;

        return ClipRRect(
            borderRadius: BorderRadius.circular(8 * sizeUnit),
            child: InkWell(
              onTap: () => controller.showImageDialog(image.fileURL),
              child: GetExtendedImage(
                url: image.fileURL,
                fit: BoxFit.contain,
                height: height.isNaN ? null : height,
              ),
            ));
      },
      separatorBuilder: (context, index) => SizedBox(height: 16 * sizeUnit),
    );
  }

  // 파일
  Widget buildFile() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: notice.fileList.length,
      itemBuilder: (context, index) {
        final NoticeFile file = notice.fileList[index];
        if (file.isPhoto) return const SizedBox.shrink(); // 이미지인 경우
        final String fileName = file.fileURL.split('/').last;

        return GestureDetector(
          onTap: () => controller.downloadFile(file: file),
          child: Container(
            width: double.infinity,
            height: 48 * sizeUnit,
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8 * sizeUnit),
              border: Border.all(color: iaColorRed),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              fileName,
              style: STextStyle.button().copyWith(
                color: iaColorRed,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 16 * sizeUnit),
    );
  }
}

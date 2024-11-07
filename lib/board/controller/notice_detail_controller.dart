import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:itall_app/data/model/notice.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/global_assets.dart';
import '../../config/global_function.dart';
import '../../config/global_widgets/get_extended_image.dart';
import '../../config/global_widgets/global_widget.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class NoticeDetailController extends GetxController {
  static get to => Get.find<NoticeDetailController>();

  late final Notice notice;

  bool haveImage = false; // 이미지 가지고 있는지 여부
  bool haveFile = false; // 파일 가지고 있는지 여부

  void initState(Notice notice) {
    this.notice = notice;
    checkFile(); // 이미지 or 파일 가지고 있는지 체크
  }

  // 이미지 or 파일 가지고 있는지 체크
  void checkFile() {
    for (NoticeFile noticeFile in notice.fileList) {
      if (noticeFile.isPhoto) {
        haveImage = true;
      } else {
        haveFile = true;
      }

      if (haveImage && haveFile) break;
    }
  }

  // 파일 다운로드
  Future<void> downloadFile({required NoticeFile file}) async {
    final String dir = (await getApplicationDocumentsDirectory()).path; //path provider로 저장할 경로 가져오기

    try {
      final downloadManager = DownloadManager();
      final task = downloadManager.getDownload(file.fileURL);

      if (task != null && !task.status.value.isCompleted) {
        switch (task.status.value) {
          case DownloadStatus.downloading:
            downloadManager.pauseDownload(file.fileURL);
            break;
          case DownloadStatus.paused:
            downloadManager.resumeDownload(file.fileURL);
            break;
        }
      } else {
        downloadManager.addDownload(file.fileURL,"$dir/${downloadManager.getFileNameFromUrl(file.fileURL)}");
      }

      GlobalFunction.showToast(msg: '파일 다운로드가 완료되었습니다.');
    } catch (e) {
      if (kDebugMode) print(e);
      GlobalFunction.showToast(msg: '다운로드에 실패했습니다.');
    }
  }

  // 이미지 다이어로그
  void showImageDialog(String url) {
    Get.dialog(
      Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Center(
                child: GetExtendedImage(url: url, fit: BoxFit.contain, isZoom: true),
              ),
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.6, sigmaY: 1.6),
              child: Container(
                width: double.infinity,
                height: 56 * sizeUnit,
                padding: EdgeInsets.only(right: 24 * sizeUnit),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2E37).withOpacity(0.6),
                ),
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      GallerySaver.saveImage(url).then((value) {
                        if (value == true) GlobalFunction.showToast(msg: '사진 저장 완료');
                      });
                    },
                    child: SvgPicture.asset(GlobalAssets.svgSave, width: 24 * sizeUnit),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

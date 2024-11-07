import '../../config/global_function.dart';
import '../../network/ApiProvider.dart';

class Notice {
  static const int typeStaff = 0; // 직원
  static const int typeStudent = 1; // 학생

  Notice({
    required this.id,
    required this.centerID,
    required this.targetCenter,
    required this.title,
    required this.contents,
    required this.type,
    required this.showDay,
    required this.fileList,
    required this.isShow,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int centerID;
  final String targetCenter;
  final String title;
  final String contents;
  final int type;
  final String showDay;
  final bool isShow;
  final List<NoticeFile> fileList;
  final String createdAt;
  final String updatedAt;

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
    id: json['id'],
    centerID: json['CenterID'],
    targetCenter: json['TargetCenter'],
    title: json['Title'],
    contents: json['Contents'],
    type: json['Type'],
    showDay: GlobalFunction.replaceDate(json['ShowDay'] ?? ''),
    fileList: json['NoticeFiles'] != null ? (json['NoticeFiles'] as List).map((e) => NoticeFile.fromJson(e)).toList() : [],
    isShow: json['IsShow'],
    createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
    updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
  );
}

class NoticeFile {
  NoticeFile({
    required this.id,
    required this.noticeID,
    required this.fileURL,
    required this.width,
    required this.height,
    required this.isPhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int noticeID;
  final String fileURL;
  final int width;
  final int height;
  final bool isPhoto;
  final String createdAt;
  final String updatedAt;

  factory NoticeFile.fromJson(Map<String, dynamic> json) => NoticeFile(
    id: json['id'],
    noticeID: json['NoticeID'],
    fileURL: json['FileURL'] == null ? '' : '${ApiProvider().getImgUrl}/${json['FileURL']}',
    width: json['Width'],
    height: json['Height'],
    isPhoto: json['IsPhoto'],
    createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
    updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
  );
}

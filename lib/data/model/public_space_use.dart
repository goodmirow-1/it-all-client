import '../../config/global_function.dart';

class PublicSpaceUse {

  PublicSpaceUse({
    required this.id,
    required this.userID,
    required this.publicSpaceID,
    required this.timeScheduleID,
    required this.classNum,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userID;
  final int publicSpaceID;
  final int timeScheduleID;
  final int classNum;
  final String createdAt;
  final String updatedAt;

  factory PublicSpaceUse.fromJson(Map<String, dynamic> json) => PublicSpaceUse(
    id: json['id'],
    userID: json['UserID'],
    publicSpaceID: json['PublicSpaceID'],
    timeScheduleID: json['TimeScheduleID'],
    classNum: json['Class'],
    createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
    updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
  );
}

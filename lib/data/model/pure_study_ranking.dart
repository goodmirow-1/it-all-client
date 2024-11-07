import 'package:itall_app/config/constants.dart';
import 'package:itall_app/network/ApiProvider.dart';

class PureStudyRanking {
  PureStudyRanking({
    required this.ranking,
    required this.student,
  });

  final int ranking;
  final SimpleStudent student;

  factory PureStudyRanking.fromJson(Map<String, dynamic> json) => PureStudyRanking(
    ranking: json['number'],
    student: json['student'] == null ? SimpleStudent.nullSimpleStudent : SimpleStudent.fromJson(json['student']),
  );
}

class SimpleStudent {
  SimpleStudent({
    required this.id,
    required this.name,
    required this.studyTime,
    required this.gender,
    required this.imageURL,
  });

  final int id;
  final String name;
  final int studyTime;
  final int? gender;
  final String? imageURL;

  factory SimpleStudent.fromJson(Map<String, dynamic> json) => SimpleStudent(
    id: json['UserID'],
    name: json['Name'],
    studyTime: json['MonthPureStudyTime'],
    gender: json['Gender'],
    imageURL: json['ImageURL'] == null ? null : '${ApiProvider().getImgUrl}/${json['ImageURL']}',
  );

  static SimpleStudent nullSimpleStudent = SimpleStudent(id: nullInt, name: '', studyTime: 0, gender: null, imageURL: null);
}

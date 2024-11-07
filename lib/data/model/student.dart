import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../network/ApiProvider.dart';
import 'attendance.dart';

class Student {
  static const int classifyClassStudent = 0; // 중고등
  static const int classifyClassCSAT = 1; // 수능
  static const int classifyClassAdult = 2; // 성인

  static const int stateBeforeEntering = 0; // 입학 전
  static const int stateAttendance = 1; // 등원
  static const int stateLeave = 2; // 하원
  static const int stateOuting = 3; // 외출
  static const int statePublicSpace = 4; // 공용공간
  static const int stateNotAttendance = -1; // 미등원

  static const int genderMan = 0; // 남자
  static const int genderWoman = 1; // 여자

  Student({
    required this.id,
    required this.number,
    required this.name,
    required this.type,
    this.centerName = '정보 없음',
    this.className = '',
    required this.centerID,
    required this.classID,
    required this.state,
    required this.monthPureStudyTime,
    required this.classifyClass,
    required this.examType,
    required this.examDetail,
    required this.target,
    required this.totalRewardPoint,
    required this.imageURL,
    required this.specialNote,
    required this.seatNumber,
    required this.gender,
    required this.attendances,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int number;
  final String name;
  final int type;
  final int centerID;
  final int classID;
  String centerName;
  String className;
  int state;
  final int monthPureStudyTime;
  final int classifyClass;
  final String examType;
  final String examDetail;
  final String target;
  final int totalRewardPoint;
  String? imageURL;
  final String specialNote;
  final String? seatNumber;
  final int? gender;
  List<Attendance> attendances;
  final String createdAt;
  final String updatedAt;

  factory Student.fromJson(Map<String, dynamic> json) {
    List<Attendance> attendances = [];
    if (json['Attendances'] != null) {
      attendances = (json['Attendances'] as List).map((e) => Attendance.fromJson(e)).toList();
    }

    return Student(
      id: json['UserID'],
      number: json['Number'],
      name: json['Name'],
      type: json['Type'],
      centerID: json['CenterID'],
      classID: json['ClassID'] ?? nullInt,
      state: json['State'],
      monthPureStudyTime: json['MonthPureStudyTime'],
      classifyClass: json['ClassifyClass'],
      examType: json['ExamType'],
      examDetail: json['ExamDetail'],
      target: json['Target'],
      totalRewardPoint: json['TotalRewardPoint'],
      imageURL: json['ImageURL'] == null ? null : '${ApiProvider().getImgUrl}/${json['ImageURL']}',
      specialNote: json['SpecialNote'] ?? '',
      seatNumber: json['Seat'] == null ? null : json['Seat']['Number'],
      gender: json['Gender'],
      attendances: attendances,
      createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
      updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
    );
  }

  // classifyClass -> text
  static String classifyClassToText(int classifyClass) {
    switch (classifyClass) {
      case Student.classifyClassStudent: // 중고등
        return '중고등';
      case Student.classifyClassCSAT: // 수능
        return '수능';
      case Student.classifyClassAdult: // 성인
        return '성인';
      default:
        return '';
    }
  }

  // state -> text
  static String stateToText(int state) {
    switch (state) {
      case Student.stateBeforeEntering: // 입학 전
        return '입학전';
      case Student.stateAttendance: // 등원
        return '등원';
      case Student.stateLeave: // 하원
        return '하원';
      case Student.stateOuting: // 외출
        return '외출';
      case Student.statePublicSpace: // 공용공간
        return '공용공간';
      case Student.stateNotAttendance: // 미등원
        return '미등원';
      default:
        return '';
    }
  }

  // 오늘 등원했는지
  static bool isTodayAttendance(List<Attendance> attendanceList){
    final DateTime now = DateTime.now();

    // 미등원 처리
    for(Attendance attendance in attendanceList) {
      if(attendance.time.year == now.year && attendance.time.month == now.month && attendance.time.day == now.day) {
        return true; // 오늘 날짜에 데이터가 있으면
      } else if(now.difference(attendance.time).inDays >= 1) {
        return false; // 오늘 날짜에서 벗어나면
      }
    }

    return false;
  }

  static Student nullStudent = Student(
    id: nullInt,
    number: nullInt,
    name: '',
    type: nullInt,
    centerID: nullInt,
    classID: nullInt,
    state: nullInt,
    monthPureStudyTime: nullInt,
    classifyClass: nullInt,
    examType: '',
    examDetail: '',
    target: '',
    totalRewardPoint: nullInt,
    specialNote: '',
    imageURL: '',
    seatNumber: '',
    gender: null,
    attendances: [],
    createdAt: '',
    updatedAt: '',
  );
}

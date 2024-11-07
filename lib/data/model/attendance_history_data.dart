import '../../data/model/attendance.dart';

class AttendanceHistoryData {
  AttendanceHistoryData({
    required this.time,
    required this.attendanceList,
  });

  final DateTime time;
  final List<Attendance> attendanceList;

  factory AttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryData(
      time: json['Time'],
      attendanceList: json['AttendancesList'],
    );
  }

  // dummy data
  static AttendanceHistoryData dummyAttendanceHistoryData = AttendanceHistoryData(time: DateTime.now(), attendanceList: []);
}

class StudyChartData {
  StudyChartData({
    required this.studyTime,
    required this.time,
  });

  int studyTime;
  final DateTime time;

  factory StudyChartData.fromJson(Map<String, dynamic> json) {
    return StudyChartData(
      studyTime: json['Time'],
      time: DateTime.parse(json['createdAt']).add(const Duration(hours: 9)),
    );
  }
}

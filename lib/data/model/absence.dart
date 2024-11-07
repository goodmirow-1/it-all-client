import '../../config/global_function.dart';

class Absence {
  static const int typeOuting = 0; // 외출
  static const int typeEarlyLeave = 1; // 조퇴
  static const int typeAbsent = 2; // 결석
  static const int typeLateness = 3; // 지각

  Absence({
    required this.id,
    required this.userID,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.reason,
    required this.withVacation,
    required this.acception,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userID;
  final int type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String reason;
  final bool withVacation;
  bool? acception;
  final String createdAt;
  final String updatedAt;

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['id'],
      userID: json['UserID'],
      type: json['Type'],
      periodStart: DateTime.parse(json['PeriodStart']),
      periodEnd: DateTime.parse(json['PeriodEnd']),
      reason: json['Reason'],
      withVacation: json['WithVacation'],
      acception: json['Acception'],
      createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
      updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
    );
  }

  // type -> string
  static String typeToText(int type) {
    switch (type) {
      case Absence.typeOuting:
        return '외출';
      case Absence.typeEarlyLeave:
        return '조퇴';
      case Absence.typeAbsent:
        return '결석';
      case Absence.typeLateness:
        return '지각';
      default:
        return '';
    }
  }
}

class AbsenceRegular {
  static const int typeOuting = 0; // 외출
  static const int typeAbsent = 1; // 결석

  AbsenceRegular({
    required this.id,
    required this.userID,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.reason,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.acception,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userID;
  final int type;
  final String periodStart;
  final String periodEnd;
  final String reason;
  bool? acception;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;
  final String createdAt;
  final String updatedAt;

  factory AbsenceRegular.fromJson(Map<String, dynamic> json) {
    return AbsenceRegular(
      id: json['id'],
      userID: json['UserID'],
      type: json['Type'],
      periodStart: json['PeriodStart'],
      periodEnd: json['PeriodEnd'],
      reason: json['Reason'],
      monday: json['Monday'],
      tuesday: json['Tuseday'],
      wednesday: json['Wednesday'],
      thursday: json['Thursday'],
      friday: json['Friday'],
      saturday: json['Saturday'],
      sunday: json['Sunday'],
      acception: json['Acception'],
      createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
      updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
    );
  }

  // type -> string
  static String typeToText(int type) {
    switch (type) {
      case AbsenceRegular.typeOuting:
        return '외출';
      case AbsenceRegular.typeAbsent:
        return '결석';
      default:
        return '';
    }
  }
}

import '../../config/global_function.dart';

class MealUses {
  static const int typeLunch = 0; // 점심
  static const int typeDinner = 1; // 저녁
  static const int stateApplication = 0; // 신청
  static const int stateCancel = 1; // 취소

  MealUses({
    required this.id,
    required this.mealPaymentID,
    required this.userID,
    required this.useDay, // 신청 날짜
    required this.type, // 점심 or 저녁
    required this.state, // 신청 or 취소
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int mealPaymentID;
  final int userID;
  final DateTime useDay;
  final int type;
  final int state;
  final String createdAt;
  final String updatedAt;

  factory MealUses.fromJson(Map<String, dynamic> json) => MealUses(
        id: json['id'],
        mealPaymentID: json['MealPaymentID'],
        userID: json['UserID'],
        useDay: json['UseDay'],
        type: json['Type'],
        state: json['State'],
        createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
        updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
      );
}

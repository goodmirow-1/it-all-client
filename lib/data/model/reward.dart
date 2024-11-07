import '../../config/global_function.dart';

class Reward {
  Reward({
    required this.id,
    required this.userID,
    required this.targetID,
    required this.reason,
    required this.description,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userID;
  final int targetID;
  final String reason;
  final String? description;
  final int value;
  final String createdAt;
  final String updatedAt;

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['id'],
    userID: json['UserID'],
    targetID: json['TargetID'],
    reason: json['Reason'],
    description: json['Description'],
    value: json['Value'],
    createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
    updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
  );
}

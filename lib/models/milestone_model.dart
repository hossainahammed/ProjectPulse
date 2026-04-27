import 'package:hive/hive.dart';

part 'milestone_model.g.dart';

@HiveType(typeId: 1)
class Milestone extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  DateTime? deliveryDate;

  @HiveField(5)
  List<String>? assignedPeople;

  Milestone({
    required this.title,
    required this.amount,
    required this.deadline,
    this.isCompleted = false,
    this.deliveryDate,
    this.assignedPeople,
  });
}

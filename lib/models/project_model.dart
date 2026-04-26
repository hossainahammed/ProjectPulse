import 'package:hive/hive.dart';
import 'milestone_model.dart';

part 'project_model.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String clientName;

  @HiveField(3)
  double totalBudget;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  String? figmaLink;

  @HiveField(6)
  String? githubLink;

  @HiveField(7)
  List<Milestone> milestones;

  @HiveField(8)
  String? orderId;

  @HiveField(9)
  DateTime? assignDate;

  @HiveField(10)
  DateTime? deliveryDate;

  @HiveField(11)
  String? driveLink;

  Project({
    required this.id,
    required this.name,
    required this.clientName,
    required this.totalBudget,
    required this.deadline,
    this.figmaLink,
    this.githubLink,
    required this.milestones,
    this.orderId,
    this.assignDate,
    this.deliveryDate,
    this.driveLink,
  });
}

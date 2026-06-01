import 'package:cloud_firestore/cloud_firestore.dart';
import 'milestone_model.dart';

class Project {
  String id;
  String name;
  String clientName;
  double totalBudget;
  DateTime deadline;
  String? figmaLink;
  String? githubLink;
  List<Milestone> milestones;
  String? orderId;
  DateTime? assignDate;
  DateTime? deliveryDate;
  String? driveLink;
  String? kpiConfigJson;

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
    this.kpiConfigJson,
  });

  factory Project.fromJson(Map<String, dynamic> json, String documentId) {
    return Project(
      id: documentId,
      name: json['name'] as String,
      clientName: json['clientName'] as String,
      totalBudget: (json['totalBudget'] as num).toDouble(),
      deadline: (json['deadline'] as Timestamp).toDate(),
      figmaLink: json['figmaLink'] as String?,
      githubLink: json['githubLink'] as String?,
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => Milestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      orderId: json['orderId'] as String?,
      assignDate: json['assignDate'] != null
          ? (json['assignDate'] as Timestamp).toDate()
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? (json['deliveryDate'] as Timestamp).toDate()
          : null,
      driveLink: json['driveLink'] as String?,
      kpiConfigJson: json['kpiConfigJson'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'clientName': clientName,
      'totalBudget': totalBudget,
      'deadline': Timestamp.fromDate(deadline),
      'figmaLink': figmaLink,
      'githubLink': githubLink,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'orderId': orderId,
      'assignDate': assignDate != null ? Timestamp.fromDate(assignDate!) : null,
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'driveLink': driveLink,
      'kpiConfigJson': kpiConfigJson,
    };
  }
}

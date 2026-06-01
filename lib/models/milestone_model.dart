import 'package:cloud_firestore/cloud_firestore.dart';

class Milestone {
  String title;
  double amount;
  bool isCompleted;
  DateTime deadline;
  DateTime? deliveryDate;
  List<String>? assignedPeople;

  Milestone({
    required this.title,
    required this.amount,
    required this.deadline,
    this.isCompleted = false,
    this.deliveryDate,
    this.assignedPeople,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      deadline: (json['deadline'] as Timestamp).toDate(),
      deliveryDate: json['deliveryDate'] != null 
          ? (json['deliveryDate'] as Timestamp).toDate() 
          : null,
      assignedPeople: (json['assignedPeople'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'isCompleted': isCompleted,
      'deadline': Timestamp.fromDate(deadline),
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'assignedPeople': assignedPeople,
    };
  }
}

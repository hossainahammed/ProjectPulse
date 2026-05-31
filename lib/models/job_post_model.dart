import 'package:cloud_firestore/cloud_firestore.dart';

class JobPost {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final double budget;
  final DateTime postedAt;
  final String category;
  final List<String> requirements;

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.budget,
    required this.postedAt,
    required this.category,
    required this.requirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'budget': budget,
      'postedAt': Timestamp.fromDate(postedAt),
      'category': category,
      'requirements': requirements,
    };
  }

  factory JobPost.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedDate;
    final rawPostedAt = json['postedAt'];
    if (rawPostedAt is Timestamp) {
      parsedDate = rawPostedAt.toDate();
    } else if (rawPostedAt is String) {
      parsedDate = DateTime.tryParse(rawPostedAt) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return JobPost(
      id: docId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      postedAt: parsedDate,
      category: json['category'] as String? ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
    );
  }
}

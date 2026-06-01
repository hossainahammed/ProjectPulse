import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String content;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.content,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json, String documentId) {
    return Note(
      id: documentId,
      content: json['content'] as String,
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 3)
class Note extends HiveObject {
  @HiveField(0)
  String content;

  @HiveField(1)
  DateTime updatedAt;

  Note({required this.content, required this.updatedAt});
}

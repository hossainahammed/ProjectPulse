import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteController extends GetxController {
  late Box<Note> _noteBox;
  final RxString noteContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _noteBox = Hive.box<Note>('notes');
    if (_noteBox.isNotEmpty) {
      noteContent.value = _noteBox.getAt(0)?.content ?? '';
    }
  }

  void updateNote(String content) {
    noteContent.value = content;
    final note = Note(content: content, updatedAt: DateTime.now());
    if (_noteBox.isEmpty) {
      _noteBox.add(note);
    } else {
      _noteBox.putAt(0, note);
    }
  }
}

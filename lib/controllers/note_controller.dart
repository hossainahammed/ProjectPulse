import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

class NoteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxString noteContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToNotes(user.uid);
      } else {
        noteContent.value = '';
      }
    });
  }

  void _listenToNotes(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc('main_note')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final note = Note.fromJson(snapshot.data()!, snapshot.id);
        noteContent.value = note.content;
      }
    }, onError: (error) {
      Get.log('Error listening to notes: $error');
    });
  }

  Future<void> updateNote(String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    noteContent.value = content;
    final note = Note(
      id: 'main_note',
      content: content,
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc('main_note')
        .set(note.toJson());
  }
}

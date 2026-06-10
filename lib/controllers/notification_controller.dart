import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  // Settings
  final RxBool allEnabled = true.obs;
  final RxBool projectCompleteEnabled = true.obs;
  final RxBool deadlineAlertsEnabled = true.obs;
  final RxBool projectCreateEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen for auth changes to load notifications for the correct user
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToNotifications(user.uid);
      } else {
        notifications.clear();
      }
    });
  }

  void _listenToNotifications(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<AppNotification> fetchedNotifications = snapshot.docs.map((doc) {
        return AppNotification.fromJson(doc.data(), doc.id);
      }).toList();
      notifications.assignAll(fetchedNotifications);
    }, onError: (error) {
      debugPrint('Error listening to notifications: $error');
    });
  }

  void toggleAll(bool value) {
    allEnabled.value = value;
    projectCompleteEnabled.value = value;
    deadlineAlertsEnabled.value = value;
    projectCreateEnabled.value = value;
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final id = const Uuid().v4();
    final notification = AppNotification(
      id: id,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(id)
        .set(notification.toJson());
  }

  Future<void> markAsRead(AppNotification notification) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notification.id)
        .update({'isRead': true});
  }

  Future<void> deleteOne(AppNotification notification) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notification.id)
        .delete();
  }

  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

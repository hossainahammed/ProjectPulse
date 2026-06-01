import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';
import '../services/notification_service.dart';
import 'notification_controller.dart';
import 'package:uuid/uuid.dart';

class ProjectController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Project> projects = <Project>[].obs;
  final NotificationController _notificationController = Get.find<NotificationController>();

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToProjects(user.uid);
      } else {
        projects.clear();
      }
    });
  }

  void _listenToProjects(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .snapshots()
        .listen((snapshot) {
      final fetchedProjects = snapshot.docs.map((doc) {
        return Project.fromJson(doc.data(), doc.id);
      }).toList();
      projects.assignAll(fetchedProjects);
    }, onError: (error) {
      print('Error listening to projects: $error');
    });
  }

  Future<void> addProject(Project project) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (project.id.isEmpty) {
      project.id = const Uuid().v4();
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc(project.id)
        .set(project.toJson());

    // Add Notification
    await _notificationController.addNotification(
      title: 'New Project Created',
      message: 'Project "${project.name}" has been successfully created.',
      type: 'project_created',
    );

    // Schedule notifications for project deadline (2 days before)
    NotificationService.scheduleAlert(
      id: project.id.hashCode,
      title: 'Project Deadline Approaching',
      body: 'The deadline for "${project.name}" is in 2 days!',
      scheduledTime: project.deadline.subtract(const Duration(days: 2)),
    );

    // Schedule notifications for each milestone (2 days before)
    for (var i = 0; i < project.milestones.length; i++) {
      final milestone = project.milestones[i];
      NotificationService.scheduleAlert(
        id: (project.id + i.toString()).hashCode,
        title: 'Milestone Deadline Approaching',
        body: 'Milestone "${milestone.title}" in "${project.name}" is due in 2 days!',
        scheduledTime: milestone.deadline.subtract(const Duration(days: 2)),
      );
    }
  }

  Future<void> updateProject(Project project) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());

    // Reschedule notification
    NotificationService.scheduleAlert(
      id: project.id.hashCode,
      title: 'Project Deadline Approaching',
      body: 'The deadline for "${project.name}" is in 2 days!',
      scheduledTime: project.deadline.subtract(const Duration(days: 2)),
    );
  }

  Future<void> deleteProject(Project project) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final id = project.id;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc(id)
        .delete();

    NotificationService.cancelNotification(id.hashCode);
  }

  double get totalEarned {
    double total = 0;
    for (var project in projects) {
      for (var milestone in project.milestones) {
        if (milestone.isCompleted) {
          total += milestone.amount;
        }
      }
    }
    return total;
  }

  double get pendingAmount {
    double total = 0;
    for (var project in projects) {
      for (var milestone in project.milestones) {
        if (!milestone.isCompleted) {
          total += milestone.amount;
        }
      }
    }
    return total;
  }

  double getProjectProgress(Project project) {
    if (project.milestones.isEmpty) return 0.0;
    int completedCount = project.milestones.where((m) => m.isCompleted).length;
    return completedCount / project.milestones.length;
  }

  Future<void> toggleMilestone(Project project, int milestoneIndex) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final milestone = project.milestones[milestoneIndex];
    milestone.isCompleted = !milestone.isCompleted;

    if (milestone.isCompleted) {
      milestone.deliveryDate = DateTime.now();
    } else {
      milestone.deliveryDate = null;
    }

    // Check if all milestones are completed
    bool allCompleted = project.milestones.every((m) => m.isCompleted);
    if (allCompleted) {
      project.deliveryDate = DateTime.now();
      await _notificationController.addNotification(
        title: 'Project Completed! 🎉',
        message: 'All milestones for "${project.name}" are finished.',
        type: 'project_completed',
      );
    } else {
      project.deliveryDate = null;
    }

    if (milestone.isCompleted) {
      await _notificationController.addNotification(
        title: 'Milestone Finished',
        message: 'Milestone "${milestone.title}" in "${project.name}" completed.',
        type: 'milestone_completed',
      );
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());
  }

  Future<void> editMilestone(
    Project project,
    int milestoneIndex, {
    required String title,
    required double amount,
    required DateTime deadline,
    List<String>? assignedPeople,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final milestone = project.milestones[milestoneIndex];
    milestone.title = title;
    milestone.amount = amount;
    milestone.deadline = deadline;
    milestone.assignedPeople = assignedPeople;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());
  }
}

import 'package:get/get.dart';
import 'project_controller.dart';
import 'package:intl/intl.dart';

class ProjectStatsController extends GetxController {
  final ProjectController _projectController = Get.find<ProjectController>();

  // Data for Dashboard Chart: Monthly Earnings
  List<Map<String, dynamic>> getMonthlyEarnings() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM').format(month);
      double totalEarnings = 0;

      for (var project in _projectController.projects) {
        // Earnings from completed milestones in this month
        for (var milestone in project.milestones) {
          if (milestone.isCompleted && 
              milestone.deliveryDate != null &&
              milestone.deliveryDate!.year == month.year &&
              milestone.deliveryDate!.month == month.month) {
            totalEarnings += milestone.amount;
          }
        }
      }

      data.add({
        'month': monthName,
        'value': totalEarnings,
      });
    }
    return data;
  }

  // Data for Profile Chart: Learning Progress (Monthly Earnings over 6 months)
  List<Map<String, dynamic>> getLearningProgress() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM').format(month);
      double monthlyEarnings = 0;

      for (var project in _projectController.projects) {
        for (var milestone in project.milestones) {
          if (milestone.isCompleted && 
              milestone.deliveryDate != null &&
              milestone.deliveryDate!.year == month.year &&
              milestone.deliveryDate!.month == month.month) {
            monthlyEarnings += milestone.amount;
          }
        }
      }

      data.add({
        'month': monthName,
        'value': monthlyEarnings,
      });
    }
    return data;
  }

  // Data for Dashboard: Individual project earnings in current month
  List<Map<String, dynamic>> getCurrentMonthProjectsData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    for (var project in _projectController.projects) {
      double projectEarnings = 0;
      bool hasCompletedInCurrentMonth = false;

      for (var milestone in project.milestones) {
        if (milestone.isCompleted &&
            milestone.deliveryDate != null &&
            milestone.deliveryDate!.year == now.year &&
            milestone.deliveryDate!.month == now.month) {
          projectEarnings += milestone.amount;
          hasCompletedInCurrentMonth = true;
        }
      }

      if (hasCompletedInCurrentMonth) {
        data.add({
          'label': project.name,
          'value': projectEarnings,
        });
      }
    }
    
    // Default data if no projects completed
    if (data.isEmpty) {
      data.add({'label': 'No Projects', 'value': 0.0});
    }

    return data;
  }
}

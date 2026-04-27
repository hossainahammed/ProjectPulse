import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../controllers/project_controller.dart';
import '../models/project_model.dart';
import '../screens/project_details_screen.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isDark;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ProjectController controller = Get.find<ProjectController>();
    double progress = controller.getProjectProgress(project);
    bool isCompleted = progress == 1.0;

    // Status logic
    String status = 'No Milestones';
    if (!isCompleted && project.milestones.isNotEmpty) {
      final nextMilestone = project.milestones.firstWhere(
        (m) => !m.isCompleted,
        orElse: () => project.milestones.last,
      );
      status = nextMilestone.title;
    } else if (isCompleted) {
      status = 'Completed';
    }

    final Color labelGrey = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color progressColor = _getProgressColor(progress, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => ProjectDetailsScreen(project: project)),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _buildDeadlineBadge(context, project.deadline),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: labelGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.clientName,
                      style: TextStyle(color: labelGrey, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.orderId != null && project.orderId!.isNotEmpty)
                    _buildInfoTag(context, Icons.tag, 'ID: ${project.orderId}', Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
              if (project.assignDate != null || project.deliveryDate != null)
                Row(
                  children: [
                    if (project.assignDate != null)
                      Expanded(
                        child: _buildInfoTag(
                          context,
                          Icons.calendar_month,
                          'Start: ${DateFormat('MMM dd').format(project.assignDate!)}',
                          Colors.purple,
                        ),
                      ),
                    if (project.deliveryDate != null)
                      Expanded(
                        child: _buildInfoTag(
                          context,
                          Icons.check_circle,
                          'Done: ${DateFormat('MMM dd').format(project.deliveryDate!)}',
                          isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              _buildInfoTag(context, Icons.flag_rounded, 'Status: $status', Colors.orange),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget',
                        style: TextStyle(fontSize: 12, color: labelGrey),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(project.totalBudget),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearPercentIndicator(
                lineHeight: 7.0,
                percent: progress,
                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                progressColor: progressColor,
                barRadius: const Radius.circular(10),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBadge(BuildContext context, DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    Color badgeColor = isDark
        ? const Color(0xFFD946EF)
        : const Color(0xFF4F46E5);

    if (difference < 3) {
      badgeColor = Colors.red;
    } else if (difference < 7) {
      badgeColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        DateFormat('MMM dd').format(deadline),
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getProgressColor(double progress, bool isDark) {
    if (progress < 0.3) return isDark ? Colors.redAccent : Colors.red;
    if (progress < 0.7) return isDark ? Colors.orangeAccent : Colors.orange;
    return isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);
  }
}

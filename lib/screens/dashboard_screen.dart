import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:badges/badges.dart' as badges;
import '../controllers/project_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/user_controller.dart';
import '../models/project_model.dart';
import 'project_details_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import '../widgets/add_project_dialog.dart';
import '../controllers/project_stats_controller.dart';
import '../widgets/progress_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProjectController controller = Get.find<ProjectController>();
  final NotificationController notificationController =
      Get.find<NotificationController>();
  final ProjectStatsController statsController =
      Get.find<ProjectStatsController>();
  // Used so Obx tracks theme changes and rebuilds project cards instantly
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isWide ? 100 : 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Hero(
            tag: 'logo',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icon/app_icon.png',
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Text(
              'Hossain Ahammed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final unreadCount = notificationController.notifications
                .where((n) => !n.isRead)
                .length;
            return badges.Badge(
              position: badges.BadgePosition.topEnd(top: 8, end: 8),
              showBadge: unreadCount > 0,
              badgeContent: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => Get.to(() => NotificationScreen()),
              ),
            );
          }),
          GestureDetector(
            onTap: () => Get.to(() => ProfileScreen()),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                backgroundImage: const AssetImage(
                  'assets/images/user_profile.png',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFinancialSummary(context),
          // Current Month Earnings Chart — reactive to milestones AND theme
          Obx(() {
            // Observing both projects list and isDarkMode triggers rebuild on either change
            final _ = controller.projects.toList();
            final __ = _userController.isDarkMode.value;
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ProgressChartWidget(
                    data: statsController.getCurrentMonthProjectsData(),
                    title: 'Current Month Earnings',
                    showArrow: false,
                    aspectRatio: 2.5,
                  ),
                ),
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Observe both projects list and isDarkMode so theme changes rebuild cards too
              final projects = controller.projects.toList();
              final isDark = _userController.isDarkMode.value; // track theme
              if (projects.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No projects yet. Add one to get started!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              if (isWide) {
                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: 16,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 220,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return _buildProjectCard(context, projects[index], isDark);
                  },
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(context, projects[index], isDark);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(AddProjectDialog()),
        label: const Text('New Project'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(isWide ? 32 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Get.theme.colorScheme.primary,
              Get.theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Earned',
                  controller.totalEarned,
                  Colors.white,
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              Container(height: 40, width: 1, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Pending',
                  controller.pendingAmount,
                  Colors.white70,
                  Icons.hourglass_empty_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color textColor,
    IconData icon,
  ) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isWide ? 18 : 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: isWide ? 16 : 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 28 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, bool isDark) {
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

    final Color subtleGrey = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final Color labelGrey = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color progressColor = _getProgressColorFromBool(progress, isDark);

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
    Color badgeColor = Theme.of(context).brightness == Brightness.dark
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

  // Used in card builder — takes bool directly so it's safe inside Obx
  Color _getProgressColorFromBool(double progress, bool isDark) {
    if (progress < 0.3) return isDark ? Colors.redAccent : Colors.red;
    if (progress < 0.7) return isDark ? Colors.orangeAccent : Colors.orange;
    return isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);
  }

  // Kept for _buildDeadlineBadge which still has BuildContext
  Color _getProgressColor(double progress, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (progress < 0.3) return isDark ? Colors.redAccent : Colors.red;
    if (progress < 0.7) return isDark ? Colors.orangeAccent : Colors.orange;
    return isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);
  }
}

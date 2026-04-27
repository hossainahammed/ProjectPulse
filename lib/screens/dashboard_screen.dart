import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import '../controllers/project_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/user_controller.dart';
import '../models/project_model.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import '../widgets/add_project_dialog.dart';
import '../controllers/project_stats_controller.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/project_card.dart';

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
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Obx(() {
                    // Observing both projects list and isDarkMode triggers rebuild on either change
                    final _ = controller.projects.toList();
                    final __ = _userController.isDarkMode.value;
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ProgressChartWidget(
                            data: statsController.getCurrentMonthProjectsData(),
                            title: 'Current Month Earnings',
                            showArrow: false,
                            aspectRatio: isWide ? 3.0 : 2.5,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Your Projects',
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: _userController.isDarkMode.value ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  final projects = controller.projects.toList();
                  final isDark = _userController.isDarkMode.value;
                  
                  if (projects.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
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
                      ),
                    );
                  }
      
                  if (isWide) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: 16,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 260,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProjectCard(project: projects[index], isDark: isDark);
                          },
                          childCount: projects.length,
                        ),
                      ),
                    );
                  }
      
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProjectCard(project: projects[index], isDark: isDark);
                        },
                        childCount: projects.length,
                      ),
                    ),
                  );
                }),
                // Spacer for bottom navigation
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
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
        margin: const EdgeInsets.symmetric(vertical: 12),
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
            Icon(icon, size: isWide ? 20 : 16, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: isWide ? 16 : 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 32 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}


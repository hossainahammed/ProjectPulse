import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import '../controllers/project_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/user_controller.dart';

import 'notification_screen.dart';
import 'profile_screen.dart';
import '../widgets/add_project_dialog.dart';
import '../controllers/project_stats_controller.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/project_card.dart';
import '../widgets/responsive.dart';

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
    final res = context.res;
    final isWide = res.isLargeScreen;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: res.appBarHeight + (isWide ? 20 : 10),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: res.spaceLG),
          child: Container(
            padding: EdgeInsets.all(res.spaceSM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: TextStyle(
                fontSize: res.fontSM,
                color: Colors.grey[600],
              ),
            ),
            Obx(() => Text(
              _userController.name.value.isNotEmpty
                  ? _userController.name.value
                  : 'User Profile',
              style: TextStyle(
                fontSize: res.fontXL,
                fontWeight: FontWeight.bold,
              ),
            )),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: res.fontXS,
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
            onTap: () => Get.to(() => const ProfileScreen()),
            child: Padding(
              padding: EdgeInsets.only(right: res.spaceLG),
              child: Obx(() {
                final imageUrl = _userController.profileImageUrl.value;
                return CircleAvatar(
                  radius: res.size(22),
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageUrl.isNotEmpty
                      ? _userController.getProfileImageProvider(imageUrl)
                      : const AssetImage('assets/images/user_profile.png'),
                );
              }),
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
                    final _ = controller.projects.toList();
                    _userController.isDarkMode.value;
                    return Center(
                      child: SizedBox(
                        width: res.width * 0.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: res.spaceLG),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: res.spaceXL,
                    vertical: res.spaceSM,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Obx(() => Text(
                      'Your Projects',
                      style: TextStyle(
                        fontSize: res.font2XL,
                        fontWeight: FontWeight.bold,
                        color: _userController.isDarkMode.value
                            ? Colors.white
                            : Colors.black87,
                      ),
                    )),
                  ),
                ),
                Obx(() {
                  final projects = controller.projects.toList();
                  final isDark = _userController.isDarkMode.value;

                  if (projects.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_late_outlined,
                              size: res.size(64),
                              color: Colors.grey,
                            ),
                            SizedBox(height: res.spaceLG),
                            Text(
                              'No projects yet. Add one to get started!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: res.fontMD,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final hPad = isWide ? res.width * 0.05 : res.width * 0.05;

                  if (isWide) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPad,
                        vertical: res.spaceLG,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: res.isDesktop ? 3 : 2,
                          crossAxisSpacing: res.spaceXL,
                          mainAxisSpacing: res.spaceLG,
                          mainAxisExtent: res.size(260),
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProjectCard(
                              project: projects[index],
                              isDark: isDark,
                            );
                          },
                          childCount: projects.length,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: res.spaceLG,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProjectCard(
                            project: projects[index],
                            isDark: isDark,
                          );
                        },
                        childCount: projects.length,
                      ),
                    ),
                  );
                }),
                // Spacer for bottom navigation
                SliverToBoxAdapter(child: SizedBox(height: res.size(100))),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () => Get.dialog(const AddProjectDialog()),
        label: Text(
          'New Project',
          style: TextStyle(fontSize: res.fontMD),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context) {
    final res = context.res;
    final isWide = res.isLargeScreen;
    return Center(
      child: Container(
        width: res.width * 0.9,
        margin: EdgeInsets.symmetric(vertical: res.spaceMD),
        padding: EdgeInsets.all(isWide ? res.space3XL : res.spaceXL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Get.theme.colorScheme.primary,
              Get.theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(res.size(24)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.3),
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
    final res = context.res;
    final isWide = res.isLargeScreen;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isWide ? res.size(20) : res.size(16), color: textColor),
            SizedBox(width: res.spaceSM),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: isWide ? res.fontBase : res.fontMD,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: res.spaceXS + 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? res.font4XL : res.font2XL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

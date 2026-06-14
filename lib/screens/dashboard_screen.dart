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

    return Obx(() {
      final isDark = _userController.isDarkMode.value;
      final name = _userController.name.value;
      final imageUrl = _userController.profileImageUrl.value;
      final unreadCount = notificationController.notifications
          .where((n) => !n.isRead)
          .length;
      final projects = controller.projects.toList();
      final totalEarned = controller.totalEarned;
      final pendingAmount = controller.pendingAmount;
      final chartData = statsController.getCurrentMonthProjectsData();

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          toolbarHeight: res.appBarHeight + (res.isLargeScreen ? 20 : 10),
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
                () {
                  final h = DateTime.now().hour;
                  if (h < 12) return 'Good Morning,';
                  if (h < 17) return 'Good Afternoon,';
                  return 'Good Evening,';
                }(),
                style: TextStyle(
                  fontSize: res.fontSM,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                name.isNotEmpty ? name : 'User Profile',
                style: TextStyle(
                  fontSize: res.fontXL,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            badges.Badge(
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
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Get.to(() => const ProfileScreen()),
                child: Padding(
                  padding: EdgeInsets.only(right: res.spaceLG),
                  child: CircleAvatar(
                    radius: res.size(22),
                    backgroundColor: Colors.grey[200],
                    backgroundImage: imageUrl.isNotEmpty
                        ? _userController.getProfileImageProvider(imageUrl)
                        : const AssetImage('assets/images/user_profile.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: res.isDesktop
            ? _buildDesktopLayout(context, isDark, projects, totalEarned, pendingAmount, chartData)
            : _buildMobileLayout(context, isDark, projects, totalEarned, pendingAmount, chartData),
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
    });
  }

  // ── Desktop layout using WebContentWrapper and Grid ─────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    bool isDark,
    List<dynamic> projects,
    double totalEarned,
    double pendingAmount,
    List<Map<String, dynamic>> chartData,
  ) {
    final res = context.res;
    final hasProgress = !chartData.every((e) => e['value'] == 0.0);

    return WebContentWrapper(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: res.spaceXL)),

          // 3-Column Grid summary cards
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: res.spaceXL),
              child: _buildDesktopSummaryGrid(context, isDark, totalEarned, pendingAmount, projects.length),
            ),
          ),

          // Earnings Chart Card
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: res.spaceXL,
                  vertical: res.spaceXL,
                ),
                child: hasProgress
                    ? ProgressChartWidget(
                        data: chartData,
                        title: 'Current Month Earnings',
                        showArrow: false,
                        aspectRatio: 3.2,
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Month Earnings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
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
                                    'No progress yet.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: res.fontMD,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          // "Your Projects" header
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: res.spaceXL,
              vertical: res.spaceSM,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Your Projects',
                style: TextStyle(
                  fontSize: res.font2XL,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // Projects Grid - 3 columns on desktop
          if (projects.isEmpty)
            SliverFillRemaining(
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
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: res.spaceXL,
                vertical: res.spaceLG,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: res.spaceXL,
                  mainAxisSpacing: res.spaceLG,
                  mainAxisExtent: res.size(260),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProjectCard(
                    project: projects[index],
                    isDark: isDark,
                  ),
                  childCount: projects.length,
                ),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: res.size(100))),
        ],
      ),
    );
  }

  // ── Desktop summary grid structure ───────────────────────────────────────
  Widget _buildDesktopSummaryGrid(
    BuildContext context,
    bool isDark,
    double totalEarned,
    double pendingAmount,
    int totalProjects,
  ) {
    final res = context.res;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: res.spaceXL,
      mainAxisSpacing: res.spaceLG,
      childAspectRatio: 2.2,
      children: [
        _buildDesktopSummaryCard(
          context,
          'Total Earned',
          totalEarned,
          Icons.account_balance_wallet_outlined,
          const Color(0xFF10B981),
          isDark,
        ),
        _buildDesktopSummaryCard(
          context,
          'Pending Amount',
          pendingAmount,
          Icons.hourglass_empty_rounded,
          const Color(0xFFF59E0B),
          isDark,
        ),
        _buildDesktopSummaryCard(
          context,
          'Total Projects',
          totalProjects.toDouble(),
          Icons.assignment_outlined,
          const Color(0xFF3B82F6),
          isDark,
          isCount: true,
        ),
      ],
    );
  }

  Widget _buildDesktopSummaryCard(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color accentColor,
    bool isDark, {
    bool isCount = false,
  }) {
    final res = context.res;
    return Container(
      padding: EdgeInsets.all(res.spaceLG),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(res.spaceMD),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: res.size(28),
            ),
          ),
          SizedBox(width: res.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: res.fontSM,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: res.spaceXS),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isCount
                        ? amount.toInt().toString()
                        : NumberFormat.currency(symbol: '\$').format(amount),
                    style: TextStyle(
                      fontSize: res.font2XL,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile layout (original card rows) ──────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context,
    bool isDark,
    List<dynamic> projects,
    double totalEarned,
    double pendingAmount,
    List<Map<String, dynamic>> chartData,
  ) {
    final res = context.res;
    final hasProgress = !chartData.every((e) => e['value'] == 0.0);

    return Column(
      children: [
        _buildFinancialSummary(context, totalEarned, pendingAmount),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Chart
              SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: res.width * 0.9,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: res.spaceLG),
                      child: hasProgress
                          ? ProgressChartWidget(
                              data: chartData,
                              title: 'Current Month Earnings',
                              showArrow: false,
                              aspectRatio: 2.5,
                            )
                          : Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Month Earnings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Center(
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
                                          'No progress yet.',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: res.fontMD,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // "Your Projects" header
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: res.spaceXL,
                  vertical: res.spaceSM,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Your Projects',
                    style: TextStyle(
                      fontSize: res.font2XL,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),

              // Projects list / grid
              if (projects.isEmpty)
                SliverFillRemaining(
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
                )
              else if (res.isLargeScreen)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: res.spaceXL,
                    vertical: res.spaceLG,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: res.spaceXL,
                      mainAxisSpacing: res.spaceLG,
                      mainAxisExtent: res.size(260),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProjectCard(
                        project: projects[index],
                        isDark: isDark,
                      ),
                      childCount: projects.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: res.spaceXL,
                    vertical: res.spaceLG,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProjectCard(
                        project: projects[index],
                        isDark: isDark,
                      ),
                      childCount: projects.length,
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: res.size(100))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(
    BuildContext context,
    double totalEarned,
    double pendingAmount,
  ) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildSummaryItem(
                context,
                'Total Earned',
                totalEarned,
                Colors.white,
                Icons.account_balance_wallet_outlined,
              ),
            ),
            Container(height: 40, width: 1, color: Colors.white24),
            Expanded(
              child: _buildSummaryItem(
                context,
                'Pending',
                pendingAmount,
                Colors.white70,
                Icons.hourglass_empty_rounded,
              ),
            ),
          ],
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

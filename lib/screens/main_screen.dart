import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';
import 'job_post_list_screen.dart';
import 'profile_screen.dart';
import '../widgets/glass_background.dart';
import '../widgets/responsive.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const DashboardScreen(),
    const ProjectsScreen(),
    const JobPostListScreen(),
    const ProfileScreen(showBackButton: false),
  ];

  @override
  Widget build(BuildContext context) {
    final res = context.res;
    final isWide = res.isLargeScreen;

    // On wide/tablet screens, show a side navigation rail instead
    if (isWide) {
      return Scaffold(
        body: GlassBackground(
          child: Row(
            children: [
              _buildNavigationRail(context, res),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile: bottom navigation bar
    return Scaffold(
      body: GlassBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(
          res.spaceLG,
          0,
          res.spaceLG,
          res.bottomPadding + res.spaceMD,
        ),
        height: res.size(75),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(res.size(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(res.size(25)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Home', res),
              _buildNavItem(context, 1, Icons.assignment_rounded, 'Projects', res),
              _buildNavItem(context, 2, Icons.work_rounded, 'Job', res),
              _buildNavItem(context, 3, Icons.person_rounded, 'Profile', res),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, AppResponsive res) {
    final Color activeColor = Get.theme.colorScheme.primary;
    final bool isDesktop = res.isDesktop;

    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      extended: isDesktop,
      backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
      selectedIconTheme: IconThemeData(color: activeColor),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
      selectedLabelTextStyle: TextStyle(
        color: activeColor,
        fontWeight: FontWeight.bold,
        fontSize: res.fontSM,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: const Color(0xFF94A3B8),
        fontSize: res.fontSM,
      ),
      indicatorColor: activeColor.withValues(alpha: 0.15),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: Text('Projects'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.work_outline),
          selectedIcon: Icon(Icons.work_rounded),
          label: Text('Job'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('Profile'),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    AppResponsive res,
  ) {
    final bool isActive = _currentIndex == index;
    final Color activeColor = Get.theme.colorScheme.primary;
    const Color inactiveColor = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: res.spaceLG,
              vertical: res.spaceSM + 2,
            ),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(res.size(16)),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : inactiveColor,
              size: res.size(24),
            ),
          ),
          SizedBox(height: res.spaceXS + 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: res.fontXS + 1,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: EdgeInsets.only(top: res.spaceXS),
              height: res.size(4),
              width: res.size(4),
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

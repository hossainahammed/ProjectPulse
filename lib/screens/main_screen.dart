import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';
import 'calculator_screen.dart';
import 'profile_screen.dart';
import '../widgets/glass_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ProjectsScreen(),
    const CalculatorScreen(),
    const ProfileScreen(showBackButton: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width > 600 ? 40 : 16,
          0,
          MediaQuery.of(context).size.width > 600 ? 40 : 16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        height: 75,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.assignment_rounded, 'Projects'),
              _buildNavItem(2, Icons.calculate_rounded, 'Calc'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _currentIndex == index;
    Color activeColor = Get.theme.colorScheme.primary;
    Color inactiveColor = const Color(0xFF94A3B8); // Slate 400

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : inactiveColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
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

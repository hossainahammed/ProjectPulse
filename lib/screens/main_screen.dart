import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controllers/user_controller.dart';
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

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Projects'),
    _NavItem(icon: Icons.work_outline, activeIcon: Icons.work_rounded, label: 'Jobs'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final res = context.res;
    final isWide = res.isLargeScreen;

    // ── Wide (tablet/desktop): dark sidebar layout ─────────────────────────
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _DarkSidebar(
              currentIndex: _currentIndex,
              navItems: _navItems,
              isDesktop: res.isDesktop,
              onItemSelected: (index) => setState(() => _currentIndex = index),
            ),
            Expanded(
              child: GlassBackground(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Mobile: bottom navigation bar ──────────────────────────────────────
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
            children: List.generate(
              _navItems.length,
              (i) => _buildMobileNavItem(context, i, res),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(BuildContext context, int index, AppResponsive res) {
    final bool isActive = _currentIndex == index;
    final Color activeColor = Get.theme.colorScheme.primary;
    const Color inactiveColor = Color(0xFF94A3B8);
    final item = _navItems[index];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
                isActive ? item.activeIcon : item.icon,
                color: isActive ? Colors.white : inactiveColor,
                size: res.size(24),
              ),
            ),
            SizedBox(height: res.spaceXS + 2),
            Text(
              item.label,
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DARK SIDEBAR — professional web dashboard sidebar
// ═══════════════════════════════════════════════════════════════════════════

class _DarkSidebar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final bool isDesktop;
  final ValueChanged<int> onItemSelected;

  const _DarkSidebar({
    required this.currentIndex,
    required this.navItems,
    required this.isDesktop,
    required this.onItemSelected,
  });

  // Sidebar colors — always dark regardless of app theme
  static const Color _bg = Color(0xFF0F172A);
  static const Color _border = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = isDesktop ? 220.0 : 72.0;

    return Container(
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(
          right: BorderSide(color: _border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo / App name header ────────────────────────────────────
          _buildLogoHeader(context, isDesktop),

          const Divider(color: _border, height: 1, thickness: 1),
          const SizedBox(height: 8),

          // ── Section label ─────────────────────────────────────────────
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
              child: Text(
                'MENU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 4),

          // ── Nav items ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                return _SidebarNavItem(
                  item: navItems[index],
                  isActive: currentIndex == index,
                  isDesktop: isDesktop,
                  onTap: () => onItemSelected(index),
                  accent: _accent,
                );
              },
            ),
          ),

          const Divider(color: _border, height: 1, thickness: 1),

          // ── Bottom profile section ────────────────────────────────────
          _buildProfileSection(context, isDesktop),
        ],
      ),
    );
  }

  Widget _buildLogoHeader(BuildContext context, bool desktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 20.0 : 16.0,
        vertical: 20.0,
      ),
      child: desktop
          ? Row(
              children: [
                _AppLogo(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'ProjectPulse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Center(child: _AppLogo()),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool desktop) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onItemSelected(3), // Profile tab
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 16.0 : 12.0,
            vertical: 16.0,
          ),
          child: desktop
              ? GetBuilder<UserController>(
                  builder: (uc) => Row(
                    children: [
                      _ProfileAvatar(uc: uc),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  uc.name.value.isNotEmpty ? uc.name.value : 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )),
                            Obx(() => Text(
                                  uc.email.value,
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.settings_outlined,
                        color: _textMuted,
                        size: 16,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: GetBuilder<UserController>(
                    builder: (uc) => _ProfileAvatar(uc: uc),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Small nav item inside sidebar ──────────────────────────────────────────

class _SidebarNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDesktop;
  final VoidCallback onTap;
  final Color accent;

  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    required this.isDesktop,
    required this.onTap,
    required this.accent,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovered = false;

  static const Color _textMuted = Color(0xFF64748B);
  static const Color _hoverBg = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isActive;
    final Color bgColor = active
        ? widget.accent.withValues(alpha: 0.15)
        : _hovered
            ? _hoverBg
            : Colors.transparent;
    final Color iconColor = active ? widget.accent : _textMuted;
    final Color textColor = active ? Colors.white : _textMuted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 12.0 : 0.0,
            vertical: 10.0,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(color: widget.accent.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: widget.isDesktop
              ? Row(
                  children: [
                    // Active indicator bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 3,
                      height: 20,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: active ? widget.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Icon(
                      active ? widget.item.activeIcon : widget.item.icon,
                      color: iconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? widget.item.activeIcon : widget.item.icon,
                      color: iconColor,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── App logo widget ────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        'assets/icon/app_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.show_chart_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

// ── Profile avatar widget ──────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final UserController uc;
  const _ProfileAvatar({required this.uc});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final imageUrl = uc.profileImageUrl.value;
      return CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF1E293B),
        backgroundImage: imageUrl.isNotEmpty
            ? uc.getProfileImageProvider(imageUrl)
            : const AssetImage('assets/images/user_profile.png'),
      );
    });
  }
}

// ── Data model for nav items ───────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

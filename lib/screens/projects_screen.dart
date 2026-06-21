import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/project_card.dart';
import '../widgets/responsive.dart';
import '../widgets/add_project_dialog.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectController controller = Get.find<ProjectController>();
  final UserController userController = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final res = context.res;

    return Obx(() {
      final isDark = userController.isDarkMode.value;
      final bgColor =
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            'My Projects',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: res.fontXL,
            ),
          ),
          centerTitle: !res.isLargeScreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: res.isDesktop
            ? _buildDesktopLayout(context, isDark)
            : _buildMobileLayout(context, isDark),
      );
    });
  }

  // ── Desktop layout wrapping with WebContentWrapper ───────────────────────
  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    final res = context.res;
    return WebContentWrapper(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: res.spaceXL,
              vertical: res.spaceMD,
            ),
            child: _buildSearchBar(isDark, res),
          ),
          Expanded(
            child: Obx(() {
              final filteredProjects = _getFilteredProjects();

              if (filteredProjects.isEmpty) {
                return _buildEmptyState(isDark, res);
              }

              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: res.spaceXL,
                  vertical: res.spaceSM,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: res.spaceXL,
                  mainAxisSpacing: res.spaceLG,
                  mainAxisExtent: res.size(260),
                ),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: filteredProjects[index],
                    isDark: isDark,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Mobile layout (original layout behavior) ─────────────────────────────
  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    final res = context.res;
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(
            res.horizontalPadding,
            res.spaceSM,
            res.horizontalPadding,
            res.spaceLG,
          ),
          child: _buildSearchBar(isDark, res),
        ),
        Expanded(
          child: Obx(() {
            final filteredProjects = _getFilteredProjects();

            if (filteredProjects.isEmpty) {
              return _buildEmptyState(isDark, res);
            }

            if (res.isLargeScreen) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: res.horizontalPadding,
                  vertical: res.spaceSM,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: res.spaceXL,
                  mainAxisSpacing: res.spaceXS,
                  mainAxisExtent: res.size(260),
                ),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: filteredProjects[index],
                    isDark: isDark,
                  );
                },
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: res.horizontalPadding),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                return ProjectCard(
                  project: filteredProjects[index],
                  isDark: isDark,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ── Helper widgets ───────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark, AppResponsive res) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(res.size(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: res.fontMD,
        ),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.blueGrey[300],
            fontSize: res.fontMD,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Get.theme.colorScheme.primary,
            size: res.size(22),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: Colors.blueGrey[300],
                    size: res.size(20),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: res.spaceXL,
            vertical: res.spaceMD,
          ),
        ),
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppResponsive res) {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: res.size(64),
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            SizedBox(height: res.spaceXL),
            Text(
              'No matches found',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: res.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: res.spaceSM),
            Text(
              'Try adjusting your search query.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: res.fontMD,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: res.size(64),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: res.spaceXL),
          Text(
            'Ready to start?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: res.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: res.spaceSM),
          Text(
            'Create your first project to track milestones\nand manage your earnings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: res.fontMD,
              height: 1.5,
            ),
          ),
          SizedBox(height: res.spaceXL),
          ElevatedButton.icon(
            onPressed: () => Get.dialog(const AddProjectDialog()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create First Project', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: res.spaceXL, vertical: res.spaceMD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredProjects() {
    final allProjects = controller.projects.toList();

    final filtered = allProjects.where((project) {
      return project.name.toLowerCase().contains(_searchQuery) ||
          project.clientName.toLowerCase().contains(_searchQuery);
    }).toList();

    filtered.sort(
      (a, b) => a.deadline.compareTo(b.deadline),
    );

    return filtered;
  }
}

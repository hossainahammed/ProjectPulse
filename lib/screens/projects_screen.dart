import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/project_card.dart';

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
    final isDark = userController.isDarkMode.value;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('My Projects', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
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
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.blueGrey[300], fontSize: 15),
                  prefixIcon: Icon(Icons.search_rounded, color: Get.theme.colorScheme.primary),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: Icon(Icons.cancel_rounded, color: Colors.blueGrey[300]), 
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ) 
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Filter and Sort by deadline priority
              final filteredProjects = controller.projects.where((project) {
                return project.name.toLowerCase().contains(_searchQuery) || 
                       project.clientName.toLowerCase().contains(_searchQuery);
              }).toList();

              filteredProjects.sort((a, b) => a.deadline.compareTo(b.deadline));

              if (filteredProjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No projects found', 
                        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final size = MediaQuery.of(context).size;
              final isWide = size.width > 600;

              if (isWide) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 4,
                    mainAxisExtent: 260,
                  ),
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    return ProjectCard(project: filteredProjects[index], isDark: isDark);
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(project: filteredProjects[index], isDark: isDark);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}


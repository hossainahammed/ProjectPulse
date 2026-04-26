import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/project_controller.dart';
import '../models/project_model.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectController controller = Get.find<ProjectController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  hintStyle: TextStyle(color: Colors.blueGrey[300], fontSize: 15),
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
                return const Center(
                  child: Text('No projects found', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = filteredProjects[index];
                  return _buildProjectListTile(project);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectListTile(Project project) {
    final progress = controller.getProjectProgress(project);
    final daysRemaining = project.deadline.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () => Get.to(() => ProjectDetailsScreen(project: project)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          child: Text(
            project.name[0].toUpperCase(),
            style: TextStyle(color: Get.theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.clientName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: daysRemaining < 3 ? Colors.red : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM dd').format(project.deadline)} ($daysRemaining days)',
                  style: TextStyle(fontSize: 12, color: daysRemaining < 3 ? Colors.red : Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(symbol: '\$').format(project.totalBudget),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${(progress * 100).toInt()}% complete', style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/project_controller.dart';
import '../models/project_model.dart';
import '../models/project_kpi_config.dart';
import 'project_kpi_screen.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;
  final ProjectController controller = Get.find<ProjectController>();

  ProjectDetailsScreen({super.key, required this.project});

  bool _isDeletable() {
    final isCompleted = project.milestones.isNotEmpty && project.milestones.every((m) => m.isCompleted);
    if (!isCompleted) return true;
    
    if (project.deliveryDate == null) return true;

    // Calculate if 6 months have passed since delivery
    final sixMonthsInDays = 182; // Approx 6 months
    final difference = DateTime.now().difference(project.deliveryDate!).inDays;
    
    return difference >= sixMonthsInDays;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final padding = isWide ? MediaQuery.of(context).size.width * 0.1 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          if (_isDeletable())
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildLinkSection(),
            const SizedBox(height: 32),
            _buildKPICard(context),
            const SizedBox(height: 32),
            const Text(
              'Milestones',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMilestoneList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow('Client', project.clientName, Icons.person_outline),
            const Divider(height: 32),
            _buildInfoRow(
              'Deadline',
              DateFormat('MMMM dd, yyyy').format(project.deadline),
              Icons.calendar_today_outlined,
            ),
            const Divider(height: 32),
            _buildInfoRow(
              'Total Budget',
              NumberFormat.currency(symbol: '\$').format(project.totalBudget),
              Icons.attach_money,
            ),
            if (project.orderId != null && project.orderId!.isNotEmpty) ...[
              const Divider(height: 32),
              _buildInfoRow('Order ID', project.orderId!, Icons.tag),
            ],
            if (project.assignDate != null) ...[
              const Divider(height: 32),
              _buildInfoRow('Assigned Date', DateFormat('MMMM dd, yyyy').format(project.assignDate!), Icons.calendar_month),
            ],
            if (project.deliveryDate != null) ...[
              const Divider(height: 32),
              _buildInfoRow('Delivery Date', DateFormat('MMMM dd, yyyy').format(project.deliveryDate!), Icons.check_circle_outline),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Get.theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (project.figmaLink != null && project.figmaLink!.isNotEmpty)
          _buildLinkButton(
            'Figma',
            project.figmaLink!,
            const Color(0xFFF24E1E),
            Icons.design_services,
          ),
        if (project.githubLink != null && project.githubLink!.isNotEmpty)
          _buildLinkButton(
            'GitHub',
            project.githubLink!,
            const Color(0xFF24292E),
            Icons.code,
          ),
        if (project.driveLink != null && project.driveLink!.isNotEmpty)
          _buildLinkButton(
            'Drive',
            project.driveLink!,
            const Color(0xFF34A853), // Google Drive Green
            Icons.cloud_circle_outlined,
          ),
      ],
    );
  }

  Widget _buildLinkButton(String label, String url, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _launchURL(url),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildMilestoneList() {
    return Obx(() {
      // Access projects to ensure Obx tracks changes
      final _ = controller.projects.length; 
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: project.milestones.length,
        itemBuilder: (context, index) {
          final milestone = project.milestones[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Get.theme.colorScheme.outlineVariant),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: CheckboxListTile(
                value: milestone.isCompleted,
                onChanged: (val) => controller.toggleMilestone(project, index),
                activeColor: Get.theme.colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  milestone.title,
                  style: TextStyle(
                    decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(milestone.amount),
                      style: TextStyle(color: Get.theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormat('MMM dd, yyyy').format(milestone.deadline)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        if (milestone.deliveryDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.check_circle, 
                            size: 12, 
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFFD946EF) 
                              : const Color(0xFF4F46E5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Done: ${DateFormat('MMM dd').format(milestone.deliveryDate!)}',
                            style: TextStyle(
                              fontSize: 11, 
                              color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFFD946EF) 
                                : const Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (milestone.assignedPeople != null && milestone.assignedPeople!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Assigned: ${milestone.assignedPeople!.join(", ")}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not launch $urlString',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Delete Project',
      middleText: 'Are you sure you want to delete this project?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteProject(project);
        Get.back(); // Close dialog
        Get.back(); // Go back to dashboard
      },
    );
  }

  Widget _buildKPICard(BuildContext context) {
    return Obx(() {
      final freshProject = controller.projects.firstWhere((p) => p.id == project.id, orElse: () => project);
      final hasConfig = freshProject.kpiConfigJson != null && freshProject.kpiConfigJson!.isNotEmpty;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardColor = Theme.of(context).cardColor;
      
      String statusText = 'Not Configured';
      Color statusColor = Colors.grey;
      if (hasConfig) {
        try {
          final config = ProjectKpiConfig.fromJson(jsonDecode(freshProject.kpiConfigJson!));
          final activeComps = config.components
              .where((c) => c.enabled)
              .map((c) => '${c.label.split(" ").first}: ${c.percentage.toStringAsFixed(0)}%')
              .join(', ');
          statusText = activeComps.isNotEmpty ? activeComps : 'No components enabled';
          statusColor = Theme.of(context).colorScheme.primary;
        } catch (e) {
          statusText = 'Configured';
          statusColor = Theme.of(context).colorScheme.primary;
        }
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.to(() => ProjectKpiScreen(project: freshProject)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: Get.theme.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KPI & Value Distribution',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: hasConfig ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

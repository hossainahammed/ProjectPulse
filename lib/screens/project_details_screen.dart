import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/project_controller.dart';
import '../models/project_model.dart';
import '../models/project_kpi_config.dart';
import '../widgets/responsive.dart';
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
    const sixMonthsInDays = 182; // Approx 6 months
    final difference = DateTime.now().difference(project.deliveryDate!).inDays;
    
    return difference >= sixMonthsInDays;
  }

  @override
  Widget build(BuildContext context) {
    final res = context.res;
    final padding = res.isLargeScreen
        ? res.width * 0.10
        : res.horizontalPadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.name,
          style: TextStyle(fontSize: res.fontLG, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isDeletable())
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: res.space3XL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: res.space3XL),
            _buildLinkSection(),
            SizedBox(height: res.space3XL),
            _buildKPICard(context),
            SizedBox(height: res.space3XL),
            Text(
              'Milestones',
              style: TextStyle(
                fontSize: res.font2XL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: res.spaceLG),
            _buildMilestoneList(),
            SizedBox(height: res.space4XL),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Get.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
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
      final freshProject = controller.projects.firstWhere(
        (p) => p.id == project.id,
        orElse: () => project,
      );
      final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: freshProject.milestones.length,
        itemBuilder: (context, index) {
          final milestone = freshProject.milestones[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: milestone.isCompleted
                    ? Get.theme.colorScheme.primary.withValues(alpha: 0.3)
                    : Get.theme.colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top row: checkbox + title + edit button
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: CheckboxListTile(
                    value: milestone.isCompleted,
                    onChanged: (val) => controller.toggleMilestone(freshProject, index),
                    activeColor: Get.theme.colorScheme.primary,
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    title: Text(
                      milestone.title,
                      style: TextStyle(
                        decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                        color: milestone.isCompleted
                            ? Colors.grey
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                    secondary: IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Get.theme.colorScheme.primary,
                      ),
                      tooltip: 'Edit Milestone',
                      onPressed: () => _showEditMilestoneSheet(context, freshProject, index, isDark),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 13,
                              color: milestone.isCompleted ? Colors.grey : Get.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              NumberFormat.currency(symbol: '\$').format(milestone.amount),
                              style: TextStyle(
                                color: milestone.isCompleted ? Colors.grey : Get.theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
                                color: isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Done: ${DateFormat('MMM dd').format(milestone.deliveryDate!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5),
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
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
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
          snackPosition: SnackPosition.TOP,
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

  void _showEditMilestoneSheet(BuildContext context, Project proj, int index, bool isDark) {
    final milestone = proj.milestones[index];
    final titleCtrl = TextEditingController(text: milestone.title);
    final amountCtrl = TextEditingController(text: milestone.amount.toStringAsFixed(2));
    final assignCtrl = TextEditingController(
      text: (milestone.assignedPeople ?? []).join(', '),
    );
    DateTime selectedDeadline = milestone.deadline;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final primaryColor = isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);

    Get.bottomSheet(
      StatefulBuilder(builder: (ctx, setSheetState) {
        return Wrap(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: borderColor),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Milestone',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Update milestone details',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    _buildSheetTextField(
                      ctrl: titleCtrl,
                      label: 'Milestone Title',
                      icon: Icons.flag_outlined,
                      isDark: isDark,
                      inputFill: inputFill,
                      textColor: textColor,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 14),

                    // Amount
                    _buildSheetTextField(
                      ctrl: amountCtrl,
                      label: 'Amount (\$)',
                      icon: Icons.payments_outlined,
                      isDark: isDark,
                      inputFill: inputFill,
                      textColor: textColor,
                      borderColor: borderColor,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 14),

                    // Deadline picker
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDeadline,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) => Theme(
                            data: isDark
                                ? ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFFD946EF),
                                    ),
                                  )
                                : ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF4F46E5),
                                    ),
                                  ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDeadline = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[500]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Deadline: ${DateFormat('MMM dd, yyyy').format(selectedDeadline)}',
                                style: TextStyle(fontSize: 14, color: textColor),
                              ),
                            ),
                            Icon(Icons.edit_calendar_outlined, size: 16, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Assigned People
                    _buildSheetTextField(
                      ctrl: assignCtrl,
                      label: 'Assigned People (comma separated)',
                      icon: Icons.people_outline,
                      isDark: isDark,
                      inputFill: inputFill,
                      textColor: textColor,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 28),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) {
                            Get.snackbar(
                              'Validation Error',
                              'Milestone title cannot be empty.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red[700],
                              colorText: Colors.white,
                            );
                            return;
                          }
                          final amount = double.tryParse(amountCtrl.text.trim()) ?? milestone.amount;
                          final people = assignCtrl.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          Get.back(); // close sheet
                          await controller.editMilestone(
                            proj,
                            index,
                            title: title,
                            amount: amount,
                            deadline: selectedDeadline,
                            assignedPeople: people.isEmpty ? null : people,
                          );
                          Get.snackbar(
                            'Milestone Updated ✓',
                            '"$title" has been saved successfully.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: primaryColor,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: isDark ? 0 : 4,
                          shadowColor: primaryColor.withValues(alpha: 0.4),
                          side: isDark ? BorderSide(color: primaryColor, width: 1.5) : BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      isScrollControlled: true,
     // isScrollControlled: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSheetTextField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color inputFill,
    required Color textColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
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
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
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
                        color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
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

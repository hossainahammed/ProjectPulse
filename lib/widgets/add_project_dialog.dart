import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/milestone_model.dart';
import '../controllers/project_controller.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  final _figmaController = TextEditingController();
  final _githubController = TextEditingController();
  final _orderIdController = TextEditingController();
  final _driveController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  DateTime _assignDate = DateTime.now();
  final List<Milestone> _milestones = [];

  void _addMilestone() {
    setState(() {
      _milestones.add(Milestone(
        title: '',
        amount: 0.0,
        deadline: DateTime.now().add(const Duration(days: 7)),
      ));
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Project',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, 'Project Name', Icons.work_outline, isRequired: true),
                _buildTextField(_clientController, 'Client Name', Icons.person_outline, isRequired: true),
                _buildTextField(_budgetController, 'Total Budget', Icons.attach_money, isNumber: true, isRequired: true),
                _buildDatePicker(),
                _buildTextField(_figmaController, 'Figma Link (Optional)', Icons.design_services, isRequired: false),
                _buildTextField(_githubController, 'GitHub Link (Optional)', Icons.code, isRequired: false),
                _buildTextField(_driveController, 'Drive Link (Optional)', Icons.cloud_circle_outlined, isRequired: false),
                _buildTextField(_orderIdController, 'Order ID (Optional)', Icons.tag, isRequired: false),
                _buildAssignDatePicker(),
                const SizedBox(height: 20),
                const Text(
                  'Milestones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...List.generate(_milestones.length, (index) => _buildMilestoneInput(index)),
                TextButton.icon(
                  onPressed: _addMilestone,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Milestone'),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Create Project'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Deadline',
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
          ),
          child: Text(
            DateFormat('yyyy-MM-dd').format(_selectedDate),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _assignDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) setState(() => _assignDate = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Assign Date',
            prefixIcon: const Icon(Icons.calendar_month, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
          ),
          child: Text(
            DateFormat('yyyy-MM-dd').format(_assignDate),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneInput(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.theme.colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Milestone Title',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => _milestones[index].title = val,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _milestones[index].amount = double.tryParse(val) ?? 0.0,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _removeMilestone(index),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _milestones[index].deadline,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) setState(() => _milestones[index].deadline = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Milestone Deadline',
                prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.5),
              ),
              child: Text(
                DateFormat('MMM dd, yyyy').format(_milestones[index].deadline),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_milestones.isEmpty) {
        Get.snackbar('Error', 'Please add at least one milestone',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final project = Project(
        id: const Uuid().v4(),
        name: _nameController.text,
        clientName: _clientController.text,
        totalBudget: double.parse(_budgetController.text),
        deadline: _selectedDate,
        figmaLink: _figmaController.text,
        githubLink: _githubController.text,
        orderId: _orderIdController.text,
        assignDate: _assignDate,
        driveLink: _driveController.text,
        milestones: _milestones,
      );

      Get.find<ProjectController>().addProject(project);
      Get.back();
    }
  }
}

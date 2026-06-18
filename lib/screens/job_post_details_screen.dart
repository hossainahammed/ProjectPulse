import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/job_post_model.dart';
import '../controllers/user_controller.dart';
import '../controllers/job_post_controller.dart';
import '../widgets/responsive.dart';

class JobPostDetailsScreen extends StatefulWidget {
  final JobPost job;
  const JobPostDetailsScreen({super.key, required this.job});

  @override
  State<JobPostDetailsScreen> createState() => _JobPostDetailsScreenState();
}

class _JobPostDetailsScreenState extends State<JobPostDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Get.find<UserController>().isDarkMode.value;
      final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
      final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (Get.find<UserController>().isAdmin.value) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showEditJobSheet(context, isDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDeleteJob(context, isDark),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: WebContentWrapper(
        maxWidth: kWebPageMaxWidth,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.work_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job.title,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Text(widget.job.company, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(Icons.location_on_outlined, widget.job.location, isDark),
                      _buildInfoItem(Icons.category_outlined, widget.job.category, isDark),
                      _buildInfoItem(
                        Icons.payments_outlined,
                        NumberFormat.currency(symbol: '\$').format(widget.job.budget),
                        isDark,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            Text(
              widget.job.description,
              style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 32),
            Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            ...widget.job.requirements.map((req) => _buildRequirementItem(req, isDark)),
            const SizedBox(height: 40),
            // Apply Now button — dark-mode aware
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showApplySheet(context, isDark, textColor),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Apply Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: isDark ? 0 : 8,
                  shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  side: isDark ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5) : BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
    });
  }

  /// Show CV picker bottom sheet
  void _showApplySheet(BuildContext context, bool isDark, Color textColor) {
    String? cvPath;
    String? cvName;
    bool isSending = false;
    final nameCtrl = TextEditingController(text: Get.find<UserController>().name.value);
    final emailCtrl = TextEditingController(text: Get.find<UserController>().email.value);

    Get.bottomSheet(
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: StatefulBuilder(builder: (ctx, setSheetState) {
            final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Apply to ${widget.job.company}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 4),
              Text(widget.job.title, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              const SizedBox(height: 24),

              // Applicant name
              _sheetTextField(nameCtrl, 'Your Name', Icons.person_outline_rounded, isDark),
              const SizedBox(height: 12),
              _sheetTextField(emailCtrl, 'Your Email', Icons.email_outlined, isDark),
              const SizedBox(height: 20),

              // CV picker
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.single.path != null) {
                    setSheetState(() {
                      cvPath = result.files.single.path;
                      cvName = result.files.single.name;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: cvPath != null
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cvPath != null
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                          : (isDark ? Colors.white12 : Colors.grey.shade200),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cvPath != null ? Icons.picture_as_pdf_rounded : Icons.upload_file_rounded,
                        color: cvPath != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          cvName ?? 'Tap to attach your CV (PDF)',
                          style: TextStyle(
                            color: cvPath != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                            fontWeight: cvPath != null ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (cvPath != null)
                        GestureDetector(
                          onTap: () => setSheetState(() { cvPath = null; cvName = null; }),
                          child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                child: isSending
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                    : ElevatedButton.icon(
                        onPressed: cvPath == null
                            ? null
                            : () async {
                                setSheetState(() => isSending = true);
                                final success = await _submitApplication(
                                  cvPath: cvPath!,
                                  cvName: cvName!,
                                  applicantName: nameCtrl.text.trim(),
                                  applicantEmail: emailCtrl.text.trim(),
                                );
                                setSheetState(() => isSending = false);
                                Get.back(); // close sheet
                                if (success) {
                                  _showSuccessDialog(isDark);
                                } else {
                                  Get.snackbar(
                                    'Error ❌',
                                    'Could not submit application. Please try again.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red[700],
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Send Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: isDark ? 0 : 4,
                          side: isDark ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5) : BorderSide.none,
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
          ),
        ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Upload CV to Storage + save application doc to Firestore
  Future<bool> _submitApplication({
    required String cvPath,
    required String cvName,
    required String applicantName,
    required String applicantEmail,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref('job_applications/${widget.job.id}/$uid/$timestamp-$cvName');

      // Upload PDF
      final uploadTask = await storageRef.putFile(File(cvPath));
      final cvUrl = await uploadTask.ref.getDownloadURL();

      // Save application record
      await FirebaseFirestore.instance.collection('job_applications').add({
        'jobId': widget.job.id,
        'jobTitle': widget.job.title,
        'company': widget.job.company,
        'applicantUid': uid,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'cvUrl': cvUrl,
        'cvName': cvName,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error submitting application: $e');
      return false;
    }
  }

  void _showSuccessDialog(bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 54),
              ),
              const SizedBox(height: 20),
              Text(
                'Application Sent! 🎉',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your CV has been sent to ${widget.job.company}. The admin will review it shortly.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { Get.back(); Get.back(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _sheetTextField(TextEditingController ctrl, String hint, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: TextField(
        controller: ctrl,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, bool isDark, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[500]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color ?? (isDark ? Colors.grey[400] : Colors.grey[600]), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _confirmDeleteJob(BuildContext context, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text('Delete Job Post', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Are you sure you want to delete this job post? This action cannot be undone.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back(); // close dialog
              final jobCtrl = Get.find<JobPostController>();
              final success = await jobCtrl.deleteJobPost(widget.job.id);
              if (success) {
                Get.back(); // return to list
                Get.snackbar('Success', 'Job post deleted successfully', backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditJobSheet(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController(text: widget.job.title);
    final companyCtrl = TextEditingController(text: widget.job.company);
    final locationCtrl = TextEditingController(text: widget.job.location);
    final budgetCtrl = TextEditingController(text: widget.job.budget.toString());
    final descriptionCtrl = TextEditingController(text: widget.job.description);
    
    Get.bottomSheet(
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Job Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              _buildTextField(titleCtrl, 'Job Title', isDark),
              const SizedBox(height: 12),
              _buildTextField(companyCtrl, 'Company', isDark),
              const SizedBox(height: 12),
              _buildTextField(locationCtrl, 'Location', isDark),
              const SizedBox(height: 12),
              _buildTextField(budgetCtrl, 'Budget', isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(descriptionCtrl, 'Description', isDark, maxLines: 4),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final budget = double.tryParse(budgetCtrl.text) ?? widget.job.budget;
                    final updates = {
                      'title': titleCtrl.text,
                      'company': companyCtrl.text,
                      'location': locationCtrl.text,
                      'budget': budget,
                      'description': descriptionCtrl.text,
                    };
                    Get.back(); // close sheet
                    
                    final jobCtrl = Get.find<JobPostController>();
                    final success = await jobCtrl.updateJobPost(widget.job.id, updates);
                    if (success) {
                      Get.back(); // go back to refresh list
                      Get.snackbar('Success', 'Job post updated', backgroundColor: Colors.green, colorText: Colors.white);
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isDark, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/job_post_model.dart';
import '../controllers/user_controller.dart';

class JobPostDetailsScreen extends StatelessWidget {
  final JobPost job;
  const JobPostDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          color: const Color(0xFFD946EF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.work_rounded, color: Color(0xFFD946EF)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Text(job.company, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(Icons.location_on_outlined, job.location, isDark),
                      _buildInfoItem(Icons.category_outlined, job.category, isDark),
                      _buildInfoItem(Icons.payments_outlined, NumberFormat.currency(symbol: '\$').format(job.budget), isDark, color: const Color(0xFFD946EF)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            Text(
              job.description,
              style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 32),
            Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            ...job.requirements.map((req) => _buildRequirementItem(req, isDark)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar('Success', 'Application sent to ${job.company}!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD946EF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: const Color(0xFFD946EF).withValues(alpha: 0.4),
                ),
                child: const Text('Apply Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
          const Icon(Icons.check_circle, color: Color(0xFFD946EF), size: 18),
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
}

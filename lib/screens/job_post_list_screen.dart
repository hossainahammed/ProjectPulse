import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/job_post_controller.dart';
import '../controllers/user_controller.dart';
import '../models/job_post_model.dart';
import 'job_post_details_screen.dart';
import 'subscription_screen.dart';

class JobPostListScreen extends StatelessWidget {
  const JobPostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JobPostController controller = Get.put(JobPostController());
    final UserController userController = Get.find<UserController>();
    final isDark = userController.isDarkMode.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Recent Job Posts', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.jobPosts.isEmpty) {
          return const Center(child: Text('No job posts available.'));
        }

        final isPremium = userController.isPremium.value;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.jobPosts.length,
          itemBuilder: (context, index) {
            final job = controller.jobPosts[index];
            return _buildJobCard(context, job, isPremium, isDark);
          },
        );
      }),
    );
  }

  Widget _buildJobCard(BuildContext context, JobPost job, bool isPremium, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isPremium) {
            Get.to(() => JobPostDetailsScreen(job: job));
          } else {
            _showSubscriptionPrompt(context);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (!isPremium)
                    const Icon(Icons.lock_outline, size: 18, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 8),
              if (isPremium) ...[
                Row(
                  children: [
                    Icon(Icons.business_rounded, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(job.company, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(job.location, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD946EF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        NumberFormat.currency(symbol: '\$').format(job.budget),
                        style: const TextStyle(
                          color: Color(0xFFD946EF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd').format(job.postedAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  'Subscribe to Premium to see company details, location, and budget.',
                  style: TextStyle(
                    color: Colors.amber.withOpacity(0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionPrompt(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium, size: 64, color: Color(0xFFD946EF)),
              const SizedBox(height: 20),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unlock job details, budgets, and application options by subscribing to Premium.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => const SubscriptionScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

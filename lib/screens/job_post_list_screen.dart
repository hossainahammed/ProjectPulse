import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/job_post_controller.dart';
import '../controllers/user_controller.dart';
import '../models/job_post_model.dart';
import '../widgets/responsive.dart';
import 'job_post_details_screen.dart';
import 'subscription_screen.dart';
import 'admin_panel_screen.dart';

class JobPostListScreen extends StatelessWidget {
  const JobPostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JobPostController controller = Get.put(JobPostController());
    final UserController userController = Get.find<UserController>();
    final res = context.res;

    return Obx(() {
      final isDark = userController.isDarkMode.value;
      // Temporarily forced to true to show all jobs
      final isPremium = true;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Job Board',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: res.fontXL,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          centerTitle: !res.isLargeScreen,
          actions: [
            // Premium badge for non-premium users
            if (!isPremium)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => Get.to(() => const SubscriptionScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Go Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header description
            Padding(
              padding: EdgeInsets.fromLTRB(
                res.horizontalPadding, res.spaceXS, res.horizontalPadding, res.spaceMD,
              ),
              child: Text(
                isPremium
                    ? 'Exclusive job opportunities for premium members'
                    : 'Subscribe to unlock full job details & apply',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: res.fontSM,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5),
                    ),
                  );
                }

                if (controller.jobPosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: res.size(64),
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        SizedBox(height: res.spaceLG),
                        Text(
                          'No job posts available.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: res.fontBase,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchJobPosts,
                  child: res.isLargeScreen
                      ? GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            res.horizontalPadding, 0, res.horizontalPadding, 100,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: res.isDesktop ? 3 : 2,
                            crossAxisSpacing: res.spaceXL,
                            mainAxisSpacing: res.spaceMD,
                            mainAxisExtent: isPremium ? res.size(280) : res.size(180),
                          ),
                          itemCount: controller.jobPosts.length,
                          itemBuilder: (context, index) {
                            final job = controller.jobPosts[index];
                            return _buildJobCard(context, job, isPremium, isDark);
                          },
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            res.horizontalPadding, 0, res.horizontalPadding, 100,
                          ),
                          itemCount: controller.jobPosts.length,
                          itemBuilder: (context, index) {
                            final job = controller.jobPosts[index];
                            return _buildJobCard(context, job, isPremium, isDark);
                          },
                        ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: Obx(() {
          if (userController.isAdmin.value) {
            return FloatingActionButton.extended(
              heroTag: 'job_list_fab',
              backgroundColor: const Color(0xFFD946EF),
              onPressed: () => Get.to(() => const AdminPanelScreen()),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Post Job',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      );
    });
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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
            _showSubscriptionPrompt(context, isDark);
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
                  // Category icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD946EF).withValues(alpha: isDark ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(job.category),
                      color: const Color(0xFFD946EF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        if (isPremium)
                          Text(
                            job.company,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isPremium)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline, size: 16, color: Colors.amber),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (isPremium) ...[
                // Location and Category row
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.location,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        job.category,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Divider
                Divider(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Budget
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD946EF).withValues(alpha: isDark ? 0.25 : 0.1),
                            const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.15 : 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 14, color: Color(0xFFD946EF)),
                          const SizedBox(width: 4),
                          Text(
                            NumberFormat.currency(symbol: '\$').format(job.budget),
                            style: const TextStyle(
                              color: Color(0xFFD946EF),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Posted date
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(job.postedAt),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Apply button hint
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => JobPostDetailsScreen(job: job)),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('View Details & Apply'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD946EF),
                      side: const BorderSide(color: Color(0xFFD946EF), width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: isDark ? 0.1 : 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Subscribe to Premium to see company, location, budget & apply.',
                          style: TextStyle(
                            color: isDark ? Colors.amber[300] : Colors.amber[800],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mobile development':
        return Icons.smartphone_rounded;
      case 'design':
        return Icons.design_services_rounded;
      case 'backend':
        return Icons.storage_rounded;
      case 'management':
        return Icons.manage_accounts_rounded;
      case 'frontend':
        return Icons.web_rounded;
      default:
        return Icons.work_rounded;
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  void _showSubscriptionPrompt(BuildContext context, bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Premium Feature',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock job details, budgets, and application options by subscribing to Premium.',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.to(() => const SubscriptionScreen());
                  },
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('Go Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

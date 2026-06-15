import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../controllers/project_stats_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/glass_background.dart';

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = Get.find<ProjectStatsController>();
    final projectController = Get.find<ProjectController>();
    final userController = Get.find<UserController>();
    final isWide = MediaQuery.of(context).size.width > 600;
    final hPadding = isWide ? MediaQuery.of(context).size.width * 0.1 : 24.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Learning Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Obx(() {
            // Observe both projects list and isDarkMode for live reactivity
            final _ = projectController.projects.toList();
            final isDark = userController.isDarkMode.value;

            final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
            final textSub = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
            final accentColor = isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.trending_up_rounded, color: accentColor, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Earnings Growth',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Last 6 months overview',
                              style: TextStyle(color: textSub, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Bar Chart ────────────────────────────────────
                  ProgressChartWidget(
                    data: statsController.getLearningProgress(),
                    title: 'Monthly Earnings (Last 6 Months)',
                    showArrow: false,
                  ),
                  const SizedBox(height: 28),

                  // ── Stats Row ────────────────────────────────────
                 _buildStatsRow(statsController, isDark, accentColor, textPrimary, textSub),
                  const SizedBox(height: 24),

                  // ── Insight Card ─────────────────────────────────
                  _buildInsightCard(isDark, accentColor, textPrimary),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    ProjectStatsController stats,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSub,
  ) {
    final data = stats.getLearningProgress();
    double total = data.fold(0.0, (sum, item) => sum + (item['value'] as double));
    double maxMonth = data.fold(0.0, (m, item) => (item['value'] as double) > m ? item['value'] : m);
    String bestMonth = '';
    for (var item in data) {
      if ((item['value'] as double) == maxMonth) {
        bestMonth = item['month'] ?? item['label'] ?? '';
        break;
      }
    }

    return Row(
      children: [
        Expanded(child: _statCard('\$${total.toStringAsFixed(0)}', 'Total (6 mo.)', Icons.account_balance_wallet_rounded, isDark, accent, textPrimary, textSub)),
        const SizedBox(width: 14),
        Expanded(child: _statCard(bestMonth, 'Best Month', Icons.emoji_events_rounded, isDark, accent, textPrimary, textSub)),
        const SizedBox(width: 14),
        Expanded(child: _statCard('\$${maxMonth.toStringAsFixed(0)}', 'Peak Earning', Icons.arrow_upward_rounded, isDark, accent, textPrimary, textSub)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, bool isDark, Color accent, Color textPrimary, Color textSub) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: textSub),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(bool isDark, Color accent, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: accent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'You are showing steady growth! Keep completing milestones to reach your monthly earning goals.',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : const Color(0xFF1E293B),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

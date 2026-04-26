import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isYearly = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.workspace_premium_rounded, size: 64, color: const Color(0xFFD946EF)),
              const SizedBox(height: 24),
              Text(
                'Go Premium',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock the most powerful ProjectPulse assistant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              _buildBenefits(cardColor, textColor, subTextColor),
              const Spacer(),
              _buildPlanToggle(isDark, cardColor, textColor, subTextColor),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefits(Color cardColor, Color textColor, Color? subTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBenefitItem('Unlimited Projects & Milestones'),
          _buildBenefitItem('AI-Powered Deadline Estimator'),
          _buildBenefitItem('Export Invoices to PDF/Excel'),
          _buildBenefitItem('Advanced Financial Analytics'),
          _buildBenefitItem('Multi-Currency Support'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFD946EF), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(bool isDark, Color cardColor, Color textColor, Color? subTextColor) {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            'Monthly',
            '\$20.00',
            'Billed Monthly',
            !isYearly,
            () => setState(() => isYearly = false),
            isDark, textColor, subTextColor
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPlanCard(
            'Yearly',
            '\$200.00',
            'Save \$40.00',
            isYearly,
            () => setState(() => isYearly = true),
            isDark, textColor, subTextColor
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String title, String price, String sub, bool selected, VoidCallback onTap, bool isDark, Color textColor, Color? subTextColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected 
              ? const Color(0xFFD946EF).withOpacity(0.1) 
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFD946EF) : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  )
                ),
                if (selected) const Icon(Icons.check_circle, color: Color(0xFFD946EF), size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price, 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: textColor,
              )
            ),
            const SizedBox(height: 4),
            Text(
              sub, 
              style: TextStyle(
                color: subTextColor, 
                fontSize: 11
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.to(() => SubscriptionDetailScreen(isYearly: isYearly)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD946EF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          'Continue - ${isYearly ? '\$200.00 total' : '\$20.00 total'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class SubscriptionDetailScreen extends StatelessWidget {
  final bool isYearly;
  const SubscriptionDetailScreen({super.key, required this.isYearly});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Membership', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                isYearly ? 'Yearly Membership' : 'Monthly Membership',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock the most powerful ProjectPulse assistant',
                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFD946EF)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isYearly ? '\$240.00' : '\$25.00',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isYearly ? '\$200.00' : '\$20.00',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Text(isYearly ? '/Yearly' : '/Monthly', style: TextStyle(fontSize: 16, color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Save 20%', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text('Feature List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              _buildFeatureItem('Unlimited Projects & Team Members', isDark),
              _buildFeatureItem('Export Financial Reports (Invoices)', isDark),
              _buildFeatureItem('Priority Email Support', isDark),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const AddPaymentScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFFD946EF), size: 18),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFF334155), fontSize: 14)),
        ],
      ),
    );
  }
}

class AddPaymentScreen extends StatelessWidget {
  const AddPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Add Payment', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Payment Method', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              Text('Select the payment method you want to use.', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B))),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD946EF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.blue),
                    const SizedBox(width: 16),
                    Text('Stripe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const Spacer(),
                    const Icon(Icons.radio_button_checked, color: Color(0xFFD946EF)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const PaymentSummaryScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSummaryScreen extends StatelessWidget {
  const PaymentSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Summary', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Order Summary', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 40),
              _buildSummaryCard(isDark, textColor),
              const SizedBox(height: 40),
              _buildPriceRow('Amount', '\$20.00', textColor, isDark),
              _buildPriceRow('Tax', '\$1.99', textColor, isDark),
              const Divider(height: 40, color: Colors.grey),
              _buildPriceRow('Total', '\$21.99', textColor, isDark, isTotal: true),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showSuccessDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem('Unlimited Projects', textColor),
          _buildSummaryItem('AI Milestone Helper', textColor),
          _buildSummaryItem('Premium Support', textColor),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFFD946EF), size: 18),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color textColor, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, color: isTotal ? textColor : (isDark ? Colors.grey[400] : const Color(0xFF64748B)))),
        Text(value, style: TextStyle(fontSize: isTotal ? 22 : 16, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946EF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, color: Color(0xFFD946EF), size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Congratulations!', 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1E293B)
                )
              ),
              const SizedBox(height: 12),
              Text(
                'You have successfully subscribed to Premium. Enjoy all the professional benefits!',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 15),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.find<UserController>().isPremium.value = true;
                    Get.back(); // Close dialog
                    Get.back(); // Back from Summary
                    Get.back(); // Back from Add Payment
                    Get.back(); // Back from Details
                    Get.back(); // Back from Subscription Selection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

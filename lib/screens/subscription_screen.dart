import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'payment_webview_screen.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? constraints.maxWidth * 0.15 : 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD946EF).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, size: 64, color: Color(0xFFD946EF)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Go Premium',
                      style: TextStyle(
                        fontSize: isWide ? 40 : 32, 
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unlock the most powerful ProjectPulse assistant and scale your professional workflow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildBenefits(isDark, textColor, subTextColor),
                    const SizedBox(height: 40),
                    _buildPlanToggle(isDark, textColor, subTextColor),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenefits(bool isDark, Color textColor, Color? subTextColor) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBenefitItem('View Recent Job Postings', textColor),
          _buildBenefitItem('Apply to Premium Jobs', textColor),
          _buildBenefitItem('Export Invoices to PDF/Excel', textColor),
          _buildBenefitItem('Advanced Financial Analytics', textColor),
          _buildBenefitItem('AI-Powered Deadline Estimator', textColor),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFD946EF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(bool isDark, Color textColor, Color? subTextColor) {
    final userCtrl = Get.find<UserController>();
    return Obx(() {
      final monthly = userCtrl.monthlyPrice.value.toStringAsFixed(0);
      final yearly = userCtrl.yearlyPrice.value.toStringAsFixed(0);
      return Row(
        children: [
          Expanded(
            child: _buildPlanCard(
              'Monthly',
              '$monthly BDT',
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
              '$yearly BDT',
              'Save 50%',
              isYearly,
              () => setState(() => isYearly = true),
              isDark, textColor, subTextColor
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlanCard(String title, String price, String sub, bool selected, VoidCallback onTap, bool isDark, Color textColor, Color? subTextColor) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected 
              ? const Color(0xFFD946EF).withValues(alpha: 0.1) 
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFD946EF) : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: 2,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: const Color(0xFFD946EF).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
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
                    fontSize: 16,
                    color: selected ? const Color(0xFFD946EF) : textColor,
                  )
                ),
                if (selected) const Icon(Icons.check_circle, color: Color(0xFFD946EF), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              price, 
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: textColor,
              )
            ),
            const SizedBox(height: 4),
            Text(
              sub, 
              style: TextStyle(
                color: subTextColor, 
                fontSize: 12
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          shadowColor: const Color(0xFFD946EF).withValues(alpha: 0.4),
        ),
        child: Text(
          'Continue - ${isYearly ? '600 BDT total' : '100 BDT total'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        title: Text('Membership Plan', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.15 : 24.0,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isYearly ? 'Yearly Membership' : 'Monthly Membership',
                    style: TextStyle(fontSize: isWide ? 36 : 28, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock the most powerful ProjectPulse assistant and scale your professional workflow.',
                    style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFD946EF)),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isYearly ? '1,200 BDT' : '200 BDT',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isYearly ? '600 BDT' : '100 BDT',
                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Text(isYearly ? '/Year' : '/Month', style: TextStyle(fontSize: 18, color: textColor.withValues(alpha: 0.6))),
                            ],
                          ),
                          if (isYearly) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Save 50%', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text('Premium Benefits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 20),
                  _buildFeatureItem('Access Recent Job Postings', isDark),
                  _buildFeatureItem('Apply to Premium Jobs', isDark),
                  _buildFeatureItem('Export Financial Reports (Invoices)', isDark),
                  _buildFeatureItem('Advanced AI Assistance & KPI Stats', isDark),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => AddPaymentScreen(isYearly: isYearly)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD946EF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 8,
                        shadowColor: const Color(0xFFD946EF).withValues(alpha: 0.4),
                      ),
                      child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFFD946EF), size: 22),
          const SizedBox(width: 16),
          Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFF334155), fontSize: 16)),
        ],
      ),
    );
  }
}

class AddPaymentScreen extends StatefulWidget {
  final bool isYearly;
  const AddPaymentScreen({super.key, required this.isYearly});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  String selectedMethod = 'Stripe'; // 'Stripe' or 'Mobile Banking'

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
        title: Text('Payment', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? constraints.maxWidth * 0.15 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Payment Method', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Text('Select the payment method you want to use.', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 16)),
                  const SizedBox(height: 40),
                  
                  // Stripe Selection
                  GestureDetector(
                    onTap: () => setState(() => selectedMethod = 'Stripe'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selectedMethod == 'Stripe' ? const Color(0xFFD946EF) : (isDark ? Colors.white12 : Colors.grey.shade200),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.credit_card, color: Colors.blue, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              'Stripe Checkout',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            selectedMethod == 'Stripe' ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selectedMethod == 'Stripe' ? const Color(0xFFD946EF) : Colors.grey,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mobile Banking Selection
                  GestureDetector(
                    onTap: () => setState(() => selectedMethod = 'Mobile Banking'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selectedMethod == 'Mobile Banking' ? const Color(0xFFD946EF) : (isDark ? Colors.white12 : Colors.grey.shade200),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.pink.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.phone_android_rounded, color: Colors.pink, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              'Mobile Banking (bKash/Nagad)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            selectedMethod == 'Mobile Banking' ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selectedMethod == 'Mobile Banking' ? const Color(0xFFD946EF) : Colors.grey,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => PaymentSummaryScreen(
                        isYearly: widget.isYearly,
                        paymentMethod: selectedMethod,
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD946EF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 8,
                        shadowColor: const Color(0xFFD946EF).withValues(alpha: 0.4),
                      ),
                      child: const Text('Continue to Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaymentSummaryScreen extends StatelessWidget {
  final bool isYearly;
  final String paymentMethod;

  const PaymentSummaryScreen({
    super.key, 
    required this.isYearly,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final userCtrl = Get.find<UserController>();
    final monthly = userCtrl.monthlyPrice.value;
    final yearly = userCtrl.yearlyPrice.value;
    final priceAmt = isYearly ? yearly : monthly;
    final priceText = '${priceAmt.toStringAsFixed(0)} BDT';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Order Summary', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? constraints.maxWidth * 0.15 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Confirm Order', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 40),
                  _buildSummaryCard(isDark, textColor),
                  const SizedBox(height: 40),
                  _buildPriceRow('Subscription Plan', isYearly ? 'Yearly' : 'Monthly', textColor, isDark),
                  const SizedBox(height: 8),
                  _buildPriceRow('Payment Method', paymentMethod, textColor, isDark),
                  const SizedBox(height: 8),
                  _buildPriceRow('Subtotal', priceText, textColor, isDark),
                  _buildPriceRow('Tax / Service Charge', '0 BDT', textColor, isDark),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white12),
                  ),
                  _buildPriceRow('Total Amount', priceText, textColor, isDark, isTotal: true),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startPaymentFlow(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD946EF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 8,
                        shadowColor: const Color(0xFFD946EF).withValues(alpha: 0.4),
                      ),
                      child: const Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _startPaymentFlow(BuildContext context) async {
    final amountText = isYearly ? '600 BDT' : '100 BDT';
    final isStripe = paymentMethod == 'Stripe';

    // Navigate to simulated payment WebView and await response
    final result = await Get.to(() => PaymentWebViewScreen(
      paymentMethod: isStripe ? 'stripe' : 'mobile',
      amount: amountText,
      title: isStripe ? 'Stripe Checkout' : 'Mobile Banking (bKash/Nagad)',
    ));

    if (result == 'success') {
      final UserController userController = Get.find<UserController>();
      // Record transaction in Firestore and grant premium membership status
      final success = await userController.recordSubscription(
        planType: isYearly ? 'Yearly' : 'Monthly',
        amount: isYearly ? userController.yearlyPrice.value : userController.monthlyPrice.value,
        paymentMethod: paymentMethod,
      );

      if (success) {
        if (!context.mounted) return;
        _showSuccessDialog(context);
      } else {
        Get.snackbar(
          'Payment Error ❌',
          'Failed to record subscription status. Please contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Cancelled ⚠️',
        'Payment process was cancelled or failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber[700],
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSummaryCard(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem('Premium Project Access', textColor),
          _buildSummaryItem('View & Apply to Job Posts', textColor),
          _buildSummaryItem('AI Assistance & KPI Estimations', textColor),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFD946EF), size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color textColor, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, color: isTotal ? textColor : (isDark ? Colors.grey[400] : const Color(0xFF64748B)))),
        Text(value, style: TextStyle(fontSize: isTotal ? 28 : 20, fontWeight: FontWeight.bold, color: isTotal ? const Color(0xFFD946EF) : textColor)),
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
                color: Colors.black.withValues(alpha: 0.2),
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
                  color: const Color(0xFFD946EF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, color: Color(0xFFD946EF), size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Congratulations!', 
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1E293B)
                )
              ),
              const SizedBox(height: 12),
              Text(
                'You have successfully subscribed to Premium. Enjoy all the professional benefits!',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Back from Summary
                    Get.back(); // Back from Add Payment
                    Get.back(); // Back from Details
                    Get.back(); // Back from Subscription Selection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

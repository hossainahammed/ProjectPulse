import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/job_post_controller.dart';
import '../controllers/user_controller.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JobPostController _jobController = Get.find<JobPostController>();

  // Job post form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  String _selectedCategory = 'Mobile Development';

  // Pricing form controllers
  final _monthlyPriceController = TextEditingController();
  final _yearlyPriceController = TextEditingController();
  final _pricingFormKey = GlobalKey<FormState>();

  // Web links form controllers
  final _netlifyUrlController = TextEditingController();
  final _firebaseUrlController = TextEditingController();
  final _webLinksFormKey = GlobalKey<FormState>();
  bool _isLoadingWebLinks = true;

  final List<String> _categories = [
    'Mobile Development',
    'Backend',
    'Frontend',
    'Fullstack',
    'Design',
    'Management',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Pre-fill pricing fields from current observable values
    final userCtrl = Get.find<UserController>();
    _monthlyPriceController.text = userCtrl.monthlyPrice.value.toStringAsFixed(0);
    _yearlyPriceController.text = userCtrl.yearlyPrice.value.toStringAsFixed(0);
    // Pre-fill web links from Firestore
    _loadWebLinks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _monthlyPriceController.dispose();
    _yearlyPriceController.dispose();
    _netlifyUrlController.dispose();
    _firebaseUrlController.dispose();
    super.dispose();
  }

  void _submitJob() async {
    if (_formKey.currentState!.validate()) {
      final reqs = _requirementsController.text
          .split(',')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();

      final success = await _jobController.addJobPost(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        budget: double.tryParse(_budgetController.text.trim()) ?? 0.0,
        category: _selectedCategory,
        requirements: reqs.isEmpty ? ['None'] : reqs,
      );

      if (success) {
        _titleController.clear();
        _companyController.clear();
        _locationController.clear();
        _budgetController.clear();
        _descriptionController.clear();
        _requirementsController.clear();
        setState(() {
          _selectedCategory = 'Mobile Development';
        });

        Get.snackbar(
          'Success 🎉',
          'Job post created successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _updatePricing() async {
    if (!_pricingFormKey.currentState!.validate()) return;
    final monthly = double.tryParse(_monthlyPriceController.text.trim()) ?? 0;
    final yearly = double.tryParse(_yearlyPriceController.text.trim()) ?? 0;
    final userCtrl = Get.find<UserController>();
    final success = await userCtrl.updatePricing(monthly: monthly, yearly: yearly);
    if (success) {
      Get.snackbar(
        'Pricing Updated 💰',
        'Monthly: ${monthly.toStringAsFixed(0)} BDT | Yearly: ${yearly.toStringAsFixed(0)} BDT',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error ❌',
        'Failed to update pricing. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadWebLinks() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('web_links')
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _netlifyUrlController.text = data['netlify_url'] as String? ?? '';
        _firebaseUrlController.text = data['firebase_url'] as String? ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingWebLinks = false);
  }

  Future<void> _updateWebLinks() async {
    if (!_webLinksFormKey.currentState!.validate()) return;
    try {
      await FirebaseFirestore.instance
          .collection('app_config')
          .doc('web_links')
          .set({
        'netlify_url': _netlifyUrlController.text.trim(),
        'firebase_url': _firebaseUrlController.text.trim(),
      });
      Get.snackbar(
        'Web Links Updated 🌐',
        'URLs are now live for all users.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error ❌',
        'Failed to update web links. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

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
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: isDark ? Colors.grey[500] : const Color(0xFF64748B),
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.post_add_rounded), text: 'Post a Job'),
            Tab(icon: Icon(Icons.history_edu_rounded), text: 'Subscriptions'),
            Tab(icon: Icon(Icons.price_change_rounded), text: 'Pricing'),
            Tab(icon: Icon(Icons.message_rounded), text: 'Messages'),
            Tab(icon: Icon(Icons.link_rounded), text: 'Web Links'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPostJobTab(isDark, textColor),
            _buildHistoryTab(isDark, textColor),
            _buildPricingTab(isDark, textColor),
            _buildMessagesTab(isDark, textColor),
            _buildWebLinksTab(isDark, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPostJobTab(bool isDark, Color textColor) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create New Job Opportunity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter job details below to publish to the community.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Job Title',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Budget (BDT)',
                            prefixIcon: Icon(Icons.monetization_on_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v) == null) return 'Must be a number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _requirementsController,
                    decoration: const InputDecoration(
                      labelText: 'Requirements (comma separated)',
                      prefixIcon: Icon(Icons.list_alt_rounded),
                      hintText: 'e.g. Flutter dev, GetX, Hive',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Job Description',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Obx(() {
              final loading = _jobController.isLoading.value;
              return ElevatedButton(
                onPressed: loading ? null : _submitJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Publish Job Post',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTab(bool isDark, Color textColor) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _pricingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subscription Pricing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Update the pricing for monthly and yearly plans. Changes are saved to Firestore and reflect instantly in the app.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),

            // Live current pricing display via Obx
            Obx(() {
              final userCtrl = Get.find<UserController>();
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Current Monthly', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        Text(
                          '${userCtrl.monthlyPrice.value.toStringAsFixed(0)} BDT',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                    Column(
                      children: [
                        Text('Current Yearly', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        Text(
                          '${userCtrl.yearlyPrice.value.toStringAsFixed(0)} BDT',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _monthlyPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Price (BDT)',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                      hintText: 'e.g. 100',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = double.tryParse(v.trim());
                      if (val == null || val <= 0) return 'Enter a valid positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _yearlyPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Yearly Price (BDT)',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                      hintText: 'e.g. 600',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = double.tryParse(v.trim());
                      if (val == null || val <= 0) return 'Enter a valid positive number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _updatePricing,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark, Color textColor) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subscriptions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading history: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No subscriptions yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final userName = data['userName'] as String? ?? 'Anonymous';
            final userEmail = data['userEmail'] as String? ?? 'N/A';
            final planType = data['planType'] as String? ?? 'Monthly';
            final amount = data['amount']?.toString() ?? '100';
            final paymentMethod = data['paymentMethod'] as String? ?? 'Stripe';
            final Timestamp? t = data['timestamp'] as Timestamp?;
            final dateStr = t != null
                ? DateFormat('MMM dd, yyyy - hh:mm a').format(t.toDate())
                : 'Unknown Date';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Success',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                  ),
                  const Divider(height: 24, color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLAN & AMOUNT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$planType ($amount BDT)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PAYMENT METHOD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            paymentMethod,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesTab(bool isDark, Color textColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contact_messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading messages: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No messages yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] as String? ?? 'Unknown';
            final email = data['email'] as String? ?? 'N/A';
            final phone = data['phone'] as String? ?? 'N/A';
            final message = data['message'] as String? ?? '';
            final Timestamp? t = data['timestamp'] as Timestamp?;
            final dateStr = t != null
                ? DateFormat('MMM dd, yyyy - hh:mm a').format(t.toDate())
                : 'Unknown Date';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$email • $phone',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                  ),
                  const Divider(height: 24, color: Colors.white10),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWebLinksTab(bool isDark, Color textColor) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    if (_isLoadingWebLinks) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _webLinksFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Web Version Links',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Set the public URLs for the web version of ProjectPulse. These appear in the Profile screen for all users in real-time.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),

            // Live preview card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.15),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.preview_rounded, color: Color(0xFF6366F1), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Preview (what users will see)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[300] : const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _previewLinkRow(
                    icon: Icons.cloud_rounded,
                    color: const Color(0xFF00AD9F),
                    label: 'Netlify',
                    controller: _netlifyUrlController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _previewLinkRow(
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF6F00),
                    label: 'Firebase',
                    controller: _firebaseUrlController,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Form fields
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _netlifyUrlController,
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Netlify URL',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00AD9F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_rounded, color: Color(0xFF00AD9F), size: 18),
                      ),
                      hintText: 'https://your-site.netlify.app',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final uri = Uri.tryParse(v.trim());
                      if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _firebaseUrlController,
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Firebase Hosting URL',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F00).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6F00), size: 18),
                      ),
                      hintText: 'https://your-app.web.app',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final uri = Uri.tryParse(v.trim());
                      if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _updateWebLinks,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save & Publish Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewLinkRow({
    required IconData icon,
    required Color color,
    required String label,
    required TextEditingController controller,
    required bool isDark,
  }) {
    final url = controller.text.trim();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              Text(
                url.isEmpty ? '(not set)' : url,
                style: TextStyle(
                  fontSize: 12,
                  color: url.isEmpty ? Colors.grey[500] : color,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

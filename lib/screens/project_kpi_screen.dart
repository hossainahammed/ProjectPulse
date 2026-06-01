import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../models/project_kpi_config.dart';
import '../controllers/project_controller.dart';

class ComponentUiState {
  final String key;
  final String label;
  final Color themeColor;
  bool enabled;
  double percentage;
  final TextEditingController percentController;
  final TextEditingController assigneeController;
  final FocusNode assigneeFocusNode;

  ComponentUiState({
    required this.key,
    required this.label,
    required this.themeColor,
    required this.enabled,
    required this.percentage,
    required this.percentController,
    required this.assigneeController,
    required this.assigneeFocusNode,
  });
}

class ProjectKpiScreen extends StatefulWidget {
  final Project project;

  const ProjectKpiScreen({super.key, required this.project});

  @override
  State<ProjectKpiScreen> createState() => _ProjectKpiScreenState();
}

class _ProjectKpiScreenState extends State<ProjectKpiScreen> {
  final ProjectController _projectController = Get.find<ProjectController>();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  late double _totalValue;
  final TextEditingController _totalValueController = TextEditingController();
  final List<ComponentUiState> _components = [];
  
  List<String> _suggestedAssignees = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // 1. Gather milestone assignees for autocomplete suggestions
    _suggestedAssignees = widget.project.milestones
        .expand((m) => m.assignedPeople ?? <String>[])
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    // 2. Parse existing config or initialize defaults
    ProjectKpiConfig config;
    if (widget.project.kpiConfigJson != null && widget.project.kpiConfigJson!.isNotEmpty) {
      try {
        config = ProjectKpiConfig.fromJson(jsonDecode(widget.project.kpiConfigJson!));
      } catch (e) {
        config = _createDefaultConfig();
      }
    } else {
      config = _createDefaultConfig();
    }

    _totalValue = config.totalValue;
    _totalValueController.text = _totalValue.toStringAsFixed(0);

    // 3. Build UI state list
    final colorMap = {
      'web_frontend': const Color(0xFF3B82F6), // Blue
      'app_frontend': const Color(0xFFF97316), // Orange
      'figma': const Color(0xFFEC4899),        // Pink
      'backend': const Color(0xFF8B5CF6),      // Purple
    };

    _components.clear();
    for (var compConfig in config.components) {
      final pController = TextEditingController(text: _formatDouble(compConfig.percentage));
      final aController = TextEditingController(text: compConfig.assignee);
      final aFocusNode = FocusNode();

      aFocusNode.addListener(() {
        if (aFocusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });

      _components.add(ComponentUiState(
        key: compConfig.key,
        label: compConfig.label,
        themeColor: colorMap[compConfig.key] ?? Colors.indigo,
        enabled: compConfig.enabled,
        percentage: compConfig.percentage,
        percentController: pController,
        assigneeController: aController,
        assigneeFocusNode: aFocusNode,
      ));

      // Listeners to trigger instant updates
      pController.addListener(() {
        final val = double.tryParse(pController.text) ?? 0.0;
        setState(() {
          for (var comp in _components) {
            if (comp.key == compConfig.key) {
              comp.percentage = val;
            }
          }
        });
      });
    }
  }

  ProjectKpiConfig _createDefaultConfig() {
    // Check if dashboard milestone exists
    bool hasDashboard = widget.project.milestones.any((m) {
      final title = m.title.toLowerCase();
      return title.contains('dashboard') || title.contains('web') || title.contains('page');
    });

    final config = ProjectKpiConfig.defaultConfig(widget.project.totalBudget);
    
    // Customize active components based on presence of Dashboard/Web
    for (var comp in config.components) {
      if (comp.key == 'web_frontend') {
        comp.enabled = hasDashboard;
        comp.percentage = hasDashboard ? 30.0 : 0.0;
      } else if (comp.key == 'app_frontend') {
        comp.percentage = hasDashboard ? 15.0 : 45.0;
      }
    }
    return config;
  }

  double get _currentSum {
    return _components
        .where((c) => c.enabled)
        .fold(0.0, (sum, c) => sum + c.percentage);
  }

  double _round(double val) {
    return double.parse(val.toStringAsFixed(1));
  }

  String _formatDouble(double val) {
    if (val == val.toInt()) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }

  void _autoBalance() {
    final enabledComps = _components.where((c) => c.enabled).toList();
    if (enabledComps.isEmpty) return;

    double currentSum = enabledComps.fold(0.0, (sum, c) => sum + c.percentage);
    if (currentSum == 0.0) {
      double equalShare = 100.0 / enabledComps.length;
      for (var c in enabledComps) {
        c.percentage = _round(equalShare);
      }
    } else {
      for (var c in enabledComps) {
        c.percentage = (c.percentage / currentSum) * 100.0;
      }
    }

    // Adjust any rounding errors to hit exactly 100.0
    double newSum = enabledComps.fold(0.0, (sum, c) => sum + _round(c.percentage));
    double diff = 100.0 - newSum;
    if (diff != 0.0) {
      enabledComps.first.percentage += diff;
    }

    // Update text controllers without triggering infinite listener loop
    for (var c in _components) {
      if (c.enabled) {
        c.percentController.text = _formatDouble(c.percentage);
      }
    }
    setState(() {});
  }

  void _resetToDefaults() {
    bool hasWebEnabled = false;
    for (var c in _components) {
      if (c.key == 'web_frontend') {
        hasWebEnabled = c.enabled;
        break;
      }
    }

    setState(() {
      for (var c in _components) {
        if (c.key == 'web_frontend') {
          c.percentage = hasWebEnabled ? 30.0 : 0.0;
        } else if (c.key == 'app_frontend') {
          c.percentage = hasWebEnabled ? 15.0 : 45.0;
        } else if (c.key == 'figma') {
          c.percentage = 25.0;
        } else if (c.key == 'backend') {
          c.percentage = 30.0;
        }
        c.percentController.text = _formatDouble(c.percentage);
      }
    });
  }

  void _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    // Capture primary color before async gaps
    final primaryColor = Theme.of(context).colorScheme.primary;

    final enabledComps = _components.where((c) => c.enabled).toList();
    if (enabledComps.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enable at least one project component.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final double sum = _round(_currentSum);
    if (sum != 100.0) {
      Get.snackbar(
        'Validation Error',
        'Total percentage must sum to exactly 100%. Currently it is ${_formatDouble(sum)}%.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Check for empty assignees
    bool hasEmptyAssignee = enabledComps.any((c) => c.assigneeController.text.trim().isEmpty);
    if (hasEmptyAssignee) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Missing Assignees'),
          content: const Text('Some enabled components do not have an assigned employee. Do you want to save anyway?'),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Save Anyway')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    // Construct ProjectKpiConfig object
    final finalComponents = _components.map((c) => KpiComponentConfig(
      key: c.key,
      label: c.label,
      enabled: c.enabled,
      percentage: c.percentage,
      assignee: c.assigneeController.text.trim(),
    )).toList();

    final config = ProjectKpiConfig(
      totalValue: _totalValue,
      components: finalComponents,
    );

    widget.project.kpiConfigJson = jsonEncode(config.toJson());
    await _projectController.updateProject(widget.project);
    _projectController.projects.refresh();

    // Show custom success dialog popup
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 54,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Distribution Saved!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'The KPI & Value distribution plan has been successfully persisted for this project.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to Project Details screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _totalValueController.dispose();
    _scrollController.dispose();
    for (var c in _components) {
      c.percentController.dispose();
      c.assigneeController.dispose();
      c.assigneeFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final double sum = _currentSum;
    final bool isSumValid = _round(sum) == 100.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('KPI & Value Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to Defaults',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project header info card
              _buildHeaderCard(cardBgColor, primaryColor, isDark),
              const SizedBox(height: 24),
              
              // Progress/Sum Indicator Section
              _buildSumIndicatorSection(sum, isSumValid, isDark),
              const SizedBox(height: 24),
              
              // Component distribution list
              const Text(
                'Distribution Components',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              ..._components.map((c) => _buildComponentCard(c, cardBgColor, isDark)),
              
              const SizedBox(height: 250), // Extra space for keyboard and dropdown options
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 54,
        margin: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton.icon(
          onPressed: _saveConfig,
          icon: const Icon(Icons.save_rounded, color: Colors.white),
          label: const Text('Save Distribution Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color cardColor, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${widget.project.clientName}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Budget: \$${widget.project.totalBudget.toStringAsFixed(0)}',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          const Text(
            'Calculation Base (Total Value)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _totalValueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.attach_money_rounded),
              hintText: 'Enter total value to distribute',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: (val) {
              setState(() {
                _totalValue = double.tryParse(val) ?? 0.0;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Total Value is required';
              if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Enter a positive value';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSumIndicatorSection(double sum, bool isValid, bool isDark) {
    final alertColor = isValid ? Colors.green[600]! : Colors.amber[800]!;
    final alertBg = isValid ? Colors.green.withValues(alpha: 0.08) : Colors.amber.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(isValid ? Icons.check_circle_rounded : Icons.warning_rounded, color: alertColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Percentage: ${_formatDouble(sum)}%',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isValid
                          ? 'Perfect allocation distribution!'
                          : 'Allocation must sum up to exactly 100%.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isValid) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _autoBalance,
                  icon: const Icon(Icons.balance_rounded, size: 16),
                  label: const Text('Auto-Balance', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: alertColor,
                    side: BorderSide(color: alertColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildComponentCard(ComponentUiState state, Color cardColor, bool isDark) {
    final calculatedValue = (state.enabled ? state.percentage : 0.0) / 100 * _totalValue;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: state.enabled ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.enabled 
                ? state.themeColor.withValues(alpha: 0.5) 
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: state.enabled ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 1.0,
                  child: Checkbox(
                    value: state.enabled,
                    activeColor: state.themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        state.enabled = val ?? false;
                        if (!state.enabled) {
                          state.percentage = 0.0;
                          state.percentController.text = '0';
                        } else {
                          // Trigger auto-default value depending on Dashboard status
                          bool webEnabled = _components.firstWhere((c) => c.key == 'web_frontend').enabled;
                          if (state.key == 'web_frontend') {
                            state.percentage = 30.0;
                            // Also adjust App Frontend
                            _components.firstWhere((c) => c.key == 'app_frontend').percentage = 15.0;
                            _components.firstWhere((c) => c.key == 'app_frontend').percentController.text = '15';
                          } else if (state.key == 'app_frontend') {
                            state.percentage = webEnabled ? 15.0 : 45.0;
                          } else if (state.key == 'figma') {
                            state.percentage = 25.0;
                          } else if (state.key == 'backend') {
                            state.percentage = 30.0;
                          }
                          state.percentController.text = _formatDouble(state.percentage);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.label,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      decoration: !state.enabled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.key.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(color: state.themeColor, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            if (state.enabled) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: state.percentController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      decoration: InputDecoration(
                        labelText: 'Percentage (%)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      validator: (value) {
                        if (!state.enabled) return null;
                        if (value == null || value.trim().isEmpty) return 'Required';
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed < 0 || parsed > 100) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return RawAutocomplete<String>(
                          textEditingController: state.assigneeController,
                          focusNode: state.assigneeFocusNode,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _suggestedAssignees;
                            }
                            return _suggestedAssignees.where((String option) {
                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Assigned Employee',
                                prefixIcon: const Icon(Icons.person_outline, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 180),
                                  width: constraints.maxWidth,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calculated Member Value:',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(calculatedValue),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: state.themeColor,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

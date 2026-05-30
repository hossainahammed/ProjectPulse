

class KpiComponentConfig {
  final String key;
  final String label;
  bool enabled;
  double percentage;
  String assignee;

  KpiComponentConfig({
    required this.key,
    required this.label,
    this.enabled = true,
    this.percentage = 0.0,
    this.assignee = '',
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'enabled': enabled,
        'percentage': percentage,
        'assignee': assignee,
      };

  factory KpiComponentConfig.fromJson(Map<String, dynamic> json) => KpiComponentConfig(
        key: json['key'] ?? '',
        label: json['label'] ?? '',
        enabled: json['enabled'] ?? false,
        percentage: (json['percentage'] ?? 0.0).toDouble(),
        assignee: json['assignee'] ?? '',
      );
}

class ProjectKpiConfig {
  double totalValue;
  final List<KpiComponentConfig> components;

  ProjectKpiConfig({
    required this.totalValue,
    required this.components,
  });

  Map<String, dynamic> toJson() => {
        'totalValue': totalValue,
        'components': components.map((c) => c.toJson()).toList(),
      };

  factory ProjectKpiConfig.fromJson(Map<String, dynamic> json) {
    final compsRaw = json['components'] as List? ?? [];
    final comps = compsRaw.map((c) => KpiComponentConfig.fromJson(Map<String, dynamic>.from(c))).toList();
    return ProjectKpiConfig(
      totalValue: (json['totalValue'] ?? 0.0).toDouble(),
      components: comps,
    );
  }

  // Get default config for a project
  factory ProjectKpiConfig.defaultConfig(double totalBudget) {
    return ProjectKpiConfig(
      totalValue: totalBudget,
      components: [
        KpiComponentConfig(key: 'web_frontend', label: 'Web Frontend (Dashboard)', enabled: true, percentage: 30.0),
        KpiComponentConfig(key: 'app_frontend', label: 'App Frontend', enabled: true, percentage: 15.0),
        KpiComponentConfig(key: 'figma', label: 'Figma Milestone', enabled: true, percentage: 25.0),
        KpiComponentConfig(key: 'backend', label: 'Backend', enabled: true, percentage: 30.0),
      ],
    );
  }
}

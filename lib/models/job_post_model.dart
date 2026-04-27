class JobPost {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final double budget;
  final DateTime postedAt;
  final String category;
  final List<String> requirements;

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.budget,
    required this.postedAt,
    required this.category,
    required this.requirements,
  });
}

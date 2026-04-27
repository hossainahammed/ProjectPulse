import 'package:get/get.dart';
import '../models/job_post_model.dart';

class JobPostController extends GetxController {
  final RxList<JobPost> jobPosts = <JobPost>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobPosts();
  }

  Future<void> fetchJobPosts() async {
    isLoading.value = true;
    try {
      // Simulate backend API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data representing posts uploaded by admin
      final List<JobPost> mockPosts = [
        JobPost(
          id: '1',
          title: 'Senior Flutter Developer',
          description: 'We are looking for an experienced Flutter developer to lead our mobile team. You will be responsible for architecting complex solutions and mentoring junior devs.',
          company: 'TechFlow Solutions',
          location: 'Remote',
          budget: 5000,
          postedAt: DateTime.now().subtract(const Duration(hours: 2)),
          category: 'Mobile Development',
          requirements: ['4+ years Flutter experience', 'State management expertise (GetX/Riverpod)', 'Unit testing'],
        ),
        JobPost(
          id: '2',
          title: 'UI/UX Designer (Contract)',
          description: 'Looking for a creative designer to redesign our project management dashboard. Focus on modern aesthetics and smooth user flows.',
          company: 'CreativePulse',
          location: 'New York, US',
          budget: 2500,
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Design',
          requirements: ['Figma mastery', 'Portfolio of SaaS products', 'Knowledge of Material 3'],
        ),
        JobPost(
          id: '3',
          title: 'Fullstack Node.js Developer',
          description: 'Join our backend team to build scalable microservices for a high-traffic fintech application.',
          company: 'FintechHub',
          location: 'London, UK',
          budget: 4500,
          postedAt: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Backend',
          requirements: ['Node.js expert', 'PostgreSQL & Redis', 'AWS experience'],
        ),
        JobPost(
          id: '4',
          title: 'Project Manager',
          description: 'Oversee multiple high-impact projects. Ensure on-time delivery and coordinate between stakeholders.',
          company: 'GlobalLogistics',
          location: 'Hybrid',
          budget: 3800,
          postedAt: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Management',
          requirements: ['Agile/Scrum certification', '3+ years experience', 'Excellent communication'],
        ),
      ];

      jobPosts.assignAll(mockPosts);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load job posts');
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/job_post_model.dart';

class JobPostController extends GetxController {
  final RxList<JobPost> jobPosts = <JobPost>[].obs;
  final RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchJobPosts();
  }

  Future<void> fetchJobPosts() async {
    isLoading.value = true;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .orderBy('postedAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        // Seed the database with mock jobs if it is empty
        await _seedMockJobs();
        return; // _seedMockJobs will call fetchJobPosts again
      }

      final List<JobPost> fetched = snapshot.docs.map((doc) {
        return JobPost.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      jobPosts.assignAll(fetched);
    } catch (e) {
      debugPrint('Error fetching job posts: $e');
      Get.snackbar('Error', 'Failed to load job posts');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _seedMockJobs() async {
    try {
      final List<JobPost> mockPosts = [
        JobPost(
          id: '',
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
          id: '',
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
          id: '',
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
          id: '',
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

      for (var job in mockPosts) {
        await _firestore.collection('jobs').add(job.toJson());
      }

      // Re-fetch now that we have data
      await fetchJobPosts();
    } catch (e) {
      debugPrint('Error seeding mock jobs: $e');
    }
  }

  Future<bool> addJobPost({
    required String title,
    required String description,
    required String company,
    required String location,
    required double budget,
    required String category,
    required List<String> requirements,
  }) async {
    try {
      isLoading.value = true;
      final job = JobPost(
        id: '',
        title: title,
        description: description,
        company: company,
        location: location,
        budget: budget,
        postedAt: DateTime.now(),
        category: category,
        requirements: requirements,
      );

      await _firestore.collection('jobs').add(job.toJson());
      await fetchJobPosts(); // reload
      return true;
    } catch (e) {
      debugPrint('Error adding job post: $e');
      Get.snackbar('Error', 'Failed to add job post');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteJobPost(String jobId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('jobs').doc(jobId).delete();
      await fetchJobPosts(); // reload
      return true;
    } catch (e) {
      debugPrint('Error deleting job post: $e');
      Get.snackbar('Error', 'Failed to delete job post');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateJobPost(String jobId, Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      await _firestore.collection('jobs').doc(jobId).update(updates);
      await fetchJobPosts(); // reload
      return true;
    } catch (e) {
      debugPrint('Error updating job post: $e');
      Get.snackbar('Error', 'Failed to update job post');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

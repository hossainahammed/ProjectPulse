import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firebase Analytics service.
/// Usage: AnalyticsService.instance.logProjectCreated();
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── Screen Tracking ───────────────────────────────────────────────────

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('[Analytics] logScreenView error: $e');
    }
  }

  // ─── Project Events ────────────────────────────────────────────────────

  Future<void> logProjectCreated({String? projectName}) async {
    try {
      await _analytics.logEvent(
        name: 'project_created',
        parameters: {
          if (projectName != null) 'project_name': projectName,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logProjectCreated error: $e');
    }
  }

  Future<void> logProjectDeleted() async {
    try {
      await _analytics.logEvent(name: 'project_deleted');
    } catch (e) {
      debugPrint('[Analytics] logProjectDeleted error: $e');
    }
  }

  // ─── Milestone Events ──────────────────────────────────────────────────

  Future<void> logMilestoneCompleted({String? milestoneTitle}) async {
    try {
      await _analytics.logEvent(
        name: 'milestone_completed',
        parameters: {
          if (milestoneTitle != null) 'milestone_title': milestoneTitle,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logMilestoneCompleted error: $e');
    }
  }

  // ─── Job Events ────────────────────────────────────────────────────────

  Future<void> logJobViewed({String? jobTitle}) async {
    try {
      await _analytics.logEvent(
        name: 'job_viewed',
        parameters: {
          if (jobTitle != null) 'job_title': jobTitle,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logJobViewed error: $e');
    }
  }

  Future<void> logJobApplied({String? jobTitle}) async {
    try {
      await _analytics.logEvent(
        name: 'job_applied',
        parameters: {
          if (jobTitle != null) 'job_title': jobTitle,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logJobApplied error: $e');
    }
  }

  // ─── Auth Events ───────────────────────────────────────────────────────

  Future<void> logLogin({String method = 'email'}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('[Analytics] logLogin error: $e');
    }
  }

  Future<void> logSignUp({String method = 'email'}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('[Analytics] logSignUp error: $e');
    }
  }

  // ─── Subscription Events ───────────────────────────────────────────────

  Future<void> logSubscriptionUpgraded({required String plan}) async {
    try {
      await _analytics.logEvent(
        name: 'subscription_upgraded',
        parameters: {'plan': plan},
      );
    } catch (e) {
      debugPrint('[Analytics] logSubscriptionUpgraded error: $e');
    }
  }

  // ─── User Properties ──────────────────────────────────────────────────

  Future<void> setUserProperties({
    required String userId,
    String? plan,
  }) async {
    try {
      await _analytics.setUserId(id: userId);
      if (plan != null) {
        await _analytics.setUserProperty(name: 'subscription_plan', value: plan);
      }
    } catch (e) {
      debugPrint('[Analytics] setUserProperties error: $e');
    }
  }
}

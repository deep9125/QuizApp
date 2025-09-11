// lib/models/analytics/user_engagement_metric.dart

import './daily_activity.dart'; // Import the DailyActivity model

class UserEngagementMetric {
  final int activeUsersToday;
  final int newSignUpsToday;
  final int totalQuizCompletionsAllTime;
  final double averageQuizzesPerUser;
  final List<DailyActivity> dailyActivityLast7Days;

  UserEngagementMetric({
    required this.activeUsersToday,
    required this.newSignUpsToday,
    required this.totalQuizCompletionsAllTime,
    required this.averageQuizzesPerUser,
    this.dailyActivityLast7Days = const [], // Default to an empty list
  });

  // Optional: Factory constructor for JSON deserialization
  factory UserEngagementMetric.fromJson(Map<String, dynamic> json) {
    var dailyActivitiesFromJson = json['dailyActivityLast7Days'] as List?;
    List<DailyActivity> dailyActivitiesList = dailyActivitiesFromJson != null
        ? dailyActivitiesFromJson.map((i) => DailyActivity.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return UserEngagementMetric(
      activeUsersToday: json['activeUsersToday'] as int,
      newSignUpsToday: json['newSignUpsToday'] as int,
      totalQuizCompletionsAllTime: json['totalQuizCompletionsAllTime'] as int,
      averageQuizzesPerUser: (json['averageQuizzesPerUser'] as num).toDouble(),
      dailyActivityLast7Days: dailyActivitiesList,
    );
  }

  // Optional: Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'activeUsersToday': activeUsersToday,
      'newSignUpsToday': newSignUpsToday,
      'totalQuizCompletionsAllTime': totalQuizCompletionsAllTime,
      'averageQuizzesPerUser': averageQuizzesPerUser,
      'dailyActivityLast7Days': dailyActivityLast7Days.map((activity) => activity.toJson()).toList(),
    };
  }
}

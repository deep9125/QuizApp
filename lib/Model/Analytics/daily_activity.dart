// lib/models/analytics/daily_activity.dart

class DailyActivity {
  final DateTime date;
  final int activeUsers;
  final int quizzesCompleted;

  DailyActivity({
    required this.date,
    required this.activeUsers,
    required this.quizzesCompleted,
  });

  // Optional: Factory constructor for JSON deserialization
  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: DateTime.parse(json['date'] as String),
      activeUsers: json['activeUsers'] as int,
      quizzesCompleted: json['quizzesCompleted'] as int,
    );
  }

  // Optional: Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'activeUsers': activeUsers,
      'quizzesCompleted': quizzesCompleted,
    };
  }
}
